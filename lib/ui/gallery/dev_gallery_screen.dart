import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';
import '../../app/theme/tokens.dart';
import '../ui.dart';

/// Dev-only catalogue of every K component. Strings here are intentionally
/// not localised: this screen never ships in the prod flavor.
class DevGalleryScreen extends StatefulWidget {
  const DevGalleryScreen({super.key});

  @override
  State<DevGalleryScreen> createState() => _DevGalleryScreenState();
}

class _DevGalleryScreenState extends State<DevGalleryScreen> {
  bool _dark = false;
  double _scale = 1;
  bool _loading = false;
  final Set<String> _selected = <String>{'Reading'};

  static const List<(String, String)> _titles = <(String, String)>[
    ('The God of Small Things', 'Arundhati Roy'),
    ('Midnight’s Children', 'Salman Rushdie'),
    ('Pather Panchali', 'Bibhutibhushan Bandyopadhyay'),
    ('A Suitable Boy', 'Vikram Seth'),
    ('Gitanjali', 'Rabindranath Tagore'),
    (
      'The Shadow Lines: A Novel of Memory, Borders and Belonging',
      'Amitav Ghosh',
    ),
    ('Godan', 'Premchand'),
    ('Train to Pakistan', 'Khushwant Singh'),
    ('Wings of Fire', 'A. P. J. Abdul Kalam'),
    ('The White Tiger', 'Aravind Adiga'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = _dark ? AppTheme.dark : AppTheme.light;
    return Theme(
      data: theme,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_scale)),
        child: Scaffold(
          appBar: AppBar(title: const Text('Component gallery')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(KSpacing.screen),
              children: <Widget>[
                _controls(),
                _section('Covers (xs / sm / md / lg / hero)'),
                _scroll(<Widget>[
                  for (final s in KCoverSize.values)
                    KBookCover(
                      title: _titles.first.$1,
                      author: _titles.first.$2,
                      size: s,
                    ),
                ]),
                _section('Generated covers (10 titles)'),
                _scroll(<Widget>[
                  for (final t in _titles)
                    KBookCover(title: t.$1, author: t.$2, size: KCoverSize.md),
                ]),
                _section('Buttons'),
                Wrap(
                  spacing: KSpacing.md,
                  runSpacing: KSpacing.md,
                  children: <Widget>[
                    KButton(label: 'Primary', onPressed: () {}),
                    KButton(
                      label: 'Secondary',
                      variant: KButtonVariant.secondary,
                      onPressed: () {},
                    ),
                    KButton(
                      label: 'Tonal',
                      variant: KButtonVariant.tonal,
                      icon: Icons.add_rounded,
                      onPressed: () {},
                    ),
                    KButton(
                      label: 'Text',
                      variant: KButtonVariant.text,
                      onPressed: () {},
                    ),
                    KButton(label: 'Loading', loading: true, onPressed: () {}),
                    const KButton(label: 'Disabled', onPressed: null),
                    KIconButton(
                      icon: Icons.favorite_border_rounded,
                      tooltip: 'Favourite',
                      onPressed: () {},
                    ),
                  ],
                ),
                _section('Card'),
                KCard(
                  onTap: () {},
                  child: const Text('A tappable outlined card, radius 20.'),
                ),
                _section('Chips and status pills'),
                Wrap(
                  spacing: KSpacing.sm,
                  runSpacing: KSpacing.sm,
                  children: <Widget>[
                    const KChip(
                      label: 'Fiction',
                      icon: Icons.menu_book_rounded,
                    ),
                    for (final n in <String>['All', 'Reading', 'Finished'])
                      KFilterChip(
                        label: n,
                        selected: _selected.contains(n),
                        onSelected: (v) => setState(() {
                          v ? _selected.add(n) : _selected.remove(n);
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: KSpacing.md),
                Wrap(
                  spacing: KSpacing.sm,
                  runSpacing: KSpacing.sm,
                  children: <Widget>[
                    for (final s in KStatus.values) KStatusPill(status: s),
                  ],
                ),
                _section('Search field'),
                KSearchField(
                  hint: 'Search your library',
                  onChanged: (_) {},
                  onScanTap: () {},
                  scanTooltip: 'Scan a barcode',
                ),
                _section('Section header'),
                KSectionHeader(title: 'Currently reading', onSeeAll: () {}),
                _section('Progress'),
                Row(
                  children: <Widget>[
                    KProgressRing(
                      value: 0.75,
                      semanticLabel: '18 of 24 books, 75 percent',
                      child: Text(
                        '18/24',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: KSpacing.xl),
                    const Expanded(child: KProgressBar(value: 0.35)),
                  ],
                ),
                _section('Avatars'),
                const Wrap(
                  spacing: KSpacing.md,
                  children: <Widget>[
                    KAvatarInitials(name: 'Priya Sharma'),
                    KAvatarInitials(name: 'Rahul'),
                    KAvatarInitials(name: 'অনির্বাণ দাস'),
                    KAvatarInitials(name: 'Meera Nair', size: 56),
                  ],
                ),
                _section('Skeletons'),
                const SizedBox(
                  height: 220,
                  child: Row(
                    children: <Widget>[
                      KBookTileSkeleton(size: KCoverSize.sm),
                      SizedBox(width: KSpacing.lg),
                      KBookTileSkeleton(size: KCoverSize.sm),
                    ],
                  ),
                ),
                _section('Overlays'),
                Wrap(
                  spacing: KSpacing.md,
                  runSpacing: KSpacing.md,
                  children: <Widget>[
                    KButton(
                      label: 'Bottom sheet',
                      variant: KButtonVariant.tonal,
                      onPressed: () => showKBottomSheet<void>(
                        context: context,
                        builder: (_) => const Text(
                          'A sheet with a drag handle, safe-area and '
                          'keyboard awareness.',
                        ),
                      ),
                    ),
                    KButton(
                      label: 'Toast',
                      variant: KButtonVariant.tonal,
                      onPressed: () => KToast.show(
                        context,
                        'Added to Bedroom shelf',
                        actionLabel: 'View',
                        onAction: () {},
                      ),
                    ),
                    KButton(
                      label: 'Confirm dialog',
                      variant: KButtonVariant.tonal,
                      onPressed: () => showKConfirmDialog(
                        context: context,
                        title: 'Delete this book?',
                        message: 'You can undo this right after.',
                        confirmLabel: 'Delete',
                        cancelLabel: 'Cancel',
                        destructive: true,
                      ),
                    ),
                    KButton(
                      label: 'Toggle loading',
                      variant: KButtonVariant.text,
                      onPressed: () => setState(() => _loading = !_loading),
                    ),
                  ],
                ),
                if (_loading) const KSkeleton(height: 24),
                _section('Empty states'),
                for (final i in KIllustration.values)
                  SizedBox(
                    height: 380,
                    child: KEmptyState(
                      illustration: i,
                      title: 'Nothing here yet',
                      body: 'A short, warm line that says what to do next.',
                      actionLabel: 'Add your first book',
                      onAction: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _controls() {
    return Wrap(
      spacing: KSpacing.lg,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Dark'),
            Switch(value: _dark, onChanged: (v) => setState(() => _dark = v)),
          ],
        ),
        SegmentedButton<double>(
          segments: const <ButtonSegment<double>>[
            ButtonSegment<double>(value: 1, label: Text('1.0')),
            ButtonSegment<double>(value: 1.3, label: Text('1.3')),
            ButtonSegment<double>(value: 2, label: Text('2.0')),
          ],
          selected: <double>{_scale},
          onSelectionChanged: (s) => setState(() => _scale = s.first),
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: KSpacing.xl, bottom: KSpacing.md),
    child: Text(title, style: Theme.of(context).textTheme.titleLarge),
  );

  Widget _scroll(List<Widget> children) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (final c in children)
          Padding(
            padding: const EdgeInsets.only(right: KSpacing.lg),
            child: c,
          ),
      ],
    ),
  );
}
