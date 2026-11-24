import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/l10n/failure_message.dart';
import '../../../app/lending_providers.dart';
import '../../../app/providers.dart';
import '../../../app/settings_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/result.dart';
import '../../../core/text/phone.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../library/domain/book.dart';
import '../../reminders/presentation/reminder_permission.dart';
import '../domain/loan.dart';
import '../domain/loan_direction.dart';

/// The Lend / Borrow sheet. Resolves to the saved loan, or null when dismissed.
Future<Loan?> showLendSheet(
  BuildContext context, {
  required Book book,
  LoanDirection initial = LoanDirection.lent,
}) => showKBottomSheet<Loan>(
  context: context,
  builder: (_) => _LendBody(book: book, initial: initial),
);

enum _Due { none, week, twoWeeks, month, custom }

class _LendBody extends ConsumerStatefulWidget {
  const _LendBody({required this.book, required this.initial});
  final Book book;
  final LoanDirection initial;

  @override
  ConsumerState<_LendBody> createState() => _LendBodyState();
}

class _LendBodyState extends ConsumerState<_LendBody> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _note = TextEditingController();
  late LoanDirection _direction = widget.initial;
  late DateTime _start = ref.read(clockProvider).today();
  late _Due _due = _defaultDue();
  late DateTime? _customDue = _defaultCustom();
  String? _nameError;
  String? _phoneError;
  String? _error;
  bool _saving = false;

  /// The reader's default loan length, as one of the due-date choices.
  int get _defaultDays => ref.read(appSettingsProvider).defaultLoanDays;

  _Due _defaultDue() => switch (_defaultDays) {
    0 => _Due.none,
    7 => _Due.week,
    14 => _Due.twoWeeks,
    _ => _Due.custom,
  };

  DateTime? _defaultCustom() => _defaultDue() == _Due.custom
      ? DateTime(_start.year, _start.month, _start.day + _defaultDays)
      : null;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  DateTime? get _dueOn => switch (_due) {
    _Due.none => null,
    _Due.week => _start.add(const Duration(days: 7)),
    _Due.twoWeeks => _start.add(const Duration(days: 14)),
    _Due.month => DateTime(_start.year, _start.month + 1, _start.day),
    _Due.custom => _customDue,
  };

  Future<void> _pickDate({required bool due}) async {
    final today = ref.read(clockProvider).today();
    final picked = await showDatePicker(
      context: context,
      initialDate: due ? (_customDue ?? _start) : _start,
      firstDate: due ? _start : DateTime(today.year - 5),
      lastDate: DateTime(today.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (due) {
        _customDue = picked;
        _due = _Due.custom;
      } else {
        _start = picked;
        final c = _customDue;
        if (c != null && c.isBefore(picked)) _customDue = null;
      }
    });
  }

  Future<void> _fromContacts() async {
    final c = await ref.read(contactPickerProvider).pick();
    if (c == null || !mounted) return;
    setState(() {
      if (c.name.isNotEmpty) _name.text = c.name;
      if (c.phone != null) _phone.text = c.phone!;
      _nameError = null;
      _phoneError = null;
    });
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final name = _name.text.trim();
    final phoneText = _phone.text.trim();
    final cc = ref.read(defaultCountryCodeProvider);
    String? phone;
    setState(() {
      _nameError = name.isEmpty ? l10n.lendNameRequired : null;
      if (phoneText.isNotEmpty) {
        phone = normalizePhone(phoneText, defaultCountryCode: cc);
        _phoneError = phone == null ? l10n.lendPhoneInvalid : null;
      } else {
        _phoneError = null;
      }
      _error = null;
    });
    if (name.isEmpty || (phoneText.isNotEmpty && phone == null)) return;

    if (_dueOn != null) await ensureReminderPermission(context, ref);
    if (!mounted) return;
    setState(() => _saving = true);
    final lending = _direction == LoanDirection.lent;
    final r = lending
        ? await ref.read(lendBookProvider)(
            bookId: widget.book.id,
            personName: name,
            personPhone: phone,
            startedOn: _start,
            dueOn: _dueOn,
            note: _note.text,
          )
        : await ref.read(recordBorrowedBookProvider)(
            bookId: widget.book.id,
            personName: name,
            personPhone: phone,
            startedOn: _start,
            dueOn: _dueOn,
            note: _note.text,
          );
    if (!mounted) return;
    switch (r) {
      case Ok<Loan>(:final value):
        Navigator.of(context).pop(value);
      case Err<Loan>(:final failure):
        setState(() {
          _saving = false;
          _error = failureMessage(l10n, failure);
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    final cc = ref.watch(defaultCountryCodeProvider);
    final picker = ref.watch(contactPickerProvider);
    final people = ref.watch(recentPeopleProvider).value ?? const <String>[];
    final typed = _name.text.trim().toLowerCase();
    final suggestions = <String>[
      for (final p in people)
        if (p.toLowerCase() != typed &&
            (typed.isEmpty || p.toLowerCase().contains(typed)))
          p,
    ].take(5).toList();
    final lending = _direction == LoanDirection.lent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          lending ? l10n.lendSheetTitleLend : l10n.lendSheetTitleBorrow,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: KSpacing.md),
        SegmentedButton<LoanDirection>(
          segments: <ButtonSegment<LoanDirection>>[
            ButtonSegment<LoanDirection>(
              value: LoanDirection.lent,
              label: Text(l10n.lendToggleLend),
            ),
            ButtonSegment<LoanDirection>(
              value: LoanDirection.borrowed,
              label: Text(l10n.lendToggleBorrow),
            ),
          ],
          selected: <LoanDirection>{_direction},
          onSelectionChanged: (s) => setState(() => _direction = s.first),
        ),
        const SizedBox(height: KSpacing.lg),
        TextField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) => setState(() => _nameError = null),
          decoration: InputDecoration(
            labelText: lending ? l10n.lendPersonLent : l10n.lendPersonBorrowed,
            errorText: _nameError,
            suffixIcon: picker.supported
                ? IconButton(
                    tooltip: l10n.lendFromContacts,
                    icon: const Icon(Icons.contacts_outlined),
                    onPressed: _fromContacts,
                  )
                : null,
          ),
        ),
        if (suggestions.isNotEmpty) ...<Widget>[
          const SizedBox(height: KSpacing.sm),
          Wrap(
            spacing: KSpacing.sm,
            runSpacing: KSpacing.xs,
            children: <Widget>[
              for (final p in suggestions)
                ActionChip(
                  avatar: KAvatarInitials(name: p, size: 24),
                  label: Text(p),
                  onPressed: () => setState(() {
                    _name.text = p;
                    _nameError = null;
                  }),
                ),
            ],
          ),
        ],
        const SizedBox(height: KSpacing.md),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() => _phoneError = null),
          decoration: InputDecoration(
            labelText: l10n.lendPhone,
            hintText: l10n.lendPhoneHint,
            // A number picked with its own country code needs no prefix.
            prefixText: _phone.text.trimLeft().startsWith('+') ? null : '+$cc ',
            errorText: _phoneError,
          ),
        ),
        const SizedBox(height: KSpacing.lg),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(l10n.lendStarted, style: theme.textTheme.labelLarge),
            ),
            TextButton(
              onPressed: () => _pickDate(due: false),
              child: Text(fmt.format(_start)),
            ),
          ],
        ),
        Text(l10n.lendDue, style: theme.textTheme.labelLarge),
        const SizedBox(height: KSpacing.sm),
        Wrap(
          spacing: KSpacing.sm,
          runSpacing: KSpacing.sm,
          children: <Widget>[
            for (final (d, label) in <(_Due, String)>[
              (_Due.none, l10n.lendDueNone),
              (_Due.week, l10n.lendDue1w),
              (_Due.twoWeeks, l10n.lendDue2w),
              (_Due.month, l10n.lendDue1m),
            ])
              ChoiceChip(
                label: Text(label),
                selected: _due == d,
                onSelected: (_) => setState(() => _due = d),
              ),
            ChoiceChip(
              avatar: const Icon(Icons.event_outlined, size: 18),
              label: Text(
                _due == _Due.custom && _customDue != null
                    ? fmt.format(_customDue!)
                    : l10n.lendDueCustom,
              ),
              selected: _due == _Due.custom,
              onSelected: (_) => _pickDate(due: true),
            ),
          ],
        ),
        const SizedBox(height: KSpacing.lg),
        TextField(
          controller: _note,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.lendNote),
        ),
        if (_error != null) ...<Widget>[
          const SizedBox(height: KSpacing.md),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: KSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.lendSave),
          ),
        ),
      ],
    );
  }
}
