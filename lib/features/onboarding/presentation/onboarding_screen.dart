import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/location_providers.dart';
import '../../../app/providers.dart';
import '../../../app/repositories.dart';
import '../../../app/router/routes.dart';
import '../../../app/settings_providers.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../backup/presentation/backup_flows.dart';
import '../../locations/application/starter_locations.dart';

/// The first-run introduction: three short pages, a step to pick starter
/// places for books, and a choice of what to do first. Skippable at any time
/// and shown once.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const int _pages = 5;
  static const int _placesPage = 3;

  final PageController _controller = PageController();
  int _page = 0;

  /// Which starter places are ticked (all, to begin with).
  final Set<int> _picked = <int>{0, 1, 2};
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _goTo(int page) {
    if (_reduceMotion) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: KDurations.slow,
        curve: KCurves.standard,
      );
    }
  }

  void _next() => _goTo((_page + 1).clamp(0, _pages - 1));

  /// Remembers that the introduction was seen, then leaves it; [then] is
  /// opened on top of the library.
  Future<void> _finish({String? then}) async {
    final router = GoRouter.of(context);
    await ref.read(settingsRepositoryProvider).markOnboardingDone();
    router.go(Routes.library);
    if (then != null) await router.push<void>(then);
  }

  Future<void> _usePlaces(List<StarterLocation> all) async {
    setState(() => _busy = true);
    await addStarterLocations(
      ref.read(locationRepositoryProvider),
      ref.read(clockProvider),
      <StarterLocation>[
        for (var i = 0; i < all.length; i++)
          if (_picked.contains(i)) all[i],
      ],
    );
    await ref.read(starterLocationsDoneProvider.notifier).markDone();
    if (!mounted) return;
    setState(() => _busy = false);
    _next();
  }

  Future<void> _skipPlaces() async {
    await ref.read(starterLocationsDoneProvider.notifier).markDone();
    if (mounted) _next();
  }

  Future<void> _restore() async {
    final imported = await restoreBackupFlow(context, ref);
    if (imported && mounted) await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final starters = <StarterLocation>[
      StarterLocation(l10n.starterLivingRoom, 'shelf'),
      StarterLocation(l10n.starterBedroom, 'shelf'),
      StarterLocation(l10n.starterStorage, 'box'),
    ];
    final intro = <(KIllustration, String, String)>[
      (KIllustration.emptyShelf, l10n.onboarding1Title, l10n.onboarding1Body),
      (KIllustration.scannerFrame, l10n.onboarding2Title, l10n.onboarding2Body),
      (KIllustration.privateShelf, l10n.onboarding3Title, l10n.onboarding3Body),
    ];
    final skippable = _page < _pages - 1;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 56,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: skippable
                        ? Padding(
                            padding: const EdgeInsets.only(right: KSpacing.sm),
                            child: TextButton(
                              onPressed: _busy ? null : () => _finish(),
                              child: Text(l10n.onboardingSkip),
                            ),
                          )
                        : null,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: <Widget>[
                      for (var i = 0; i < intro.length; i++)
                        _IntroPage(
                          index: i,
                          controller: _controller,
                          illustration: intro[i].$1,
                          title: intro[i].$2,
                          body: intro[i].$3,
                        ),
                      _PlacesPage(
                        index: _placesPage,
                        controller: _controller,
                        starters: starters,
                        picked: _picked,
                        busy: _busy,
                        onToggle: (i) => setState(() {
                          if (!_picked.remove(i)) _picked.add(i);
                        }),
                        onUse: () => _usePlaces(starters),
                        onSkip: _skipPlaces,
                      ),
                      _ReadyPage(
                        index: 4,
                        controller: _controller,
                        onAdd: () => _finish(then: Routes.libraryAdd),
                        onRestore: _restore,
                        onExplore: () => _finish(),
                      ),
                    ],
                  ),
                ),
                _Footer(
                  page: _page,
                  pages: _pages,
                  // The last two pages carry their own buttons.
                  onNext: _page < _placesPage ? _next : null,
                  nextLabel: l10n.onboardingNext,
                  stepLabel: l10n.onboardingStep(_page + 1, _pages),
                  reduceMotion: _reduceMotion,
                ),
                const SizedBox(height: KSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Moves and fades a page's artwork a little as the page is swiped, so the
/// picture and the words travel at slightly different speeds. Nothing moves
/// when the system asks for reduced motion.
class _Parallax extends StatelessWidget {
  const _Parallax({
    required this.index,
    required this.controller,
    required this.child,
    this.strength = 70,
  });

  final int index;
  final PageController controller;
  final double strength;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final page = controller.hasClients && controller.position.haveDimensions
            ? controller.page ?? controller.initialPage.toDouble()
            : controller.initialPage.toDouble();
        final delta = (index - page).clamp(-1.0, 1.0);
        return Opacity(
          opacity: 1 - delta.abs() * 0.6,
          child: Transform.translate(
            offset: Offset(delta * strength, 0),
            child: child,
          ),
        );
      },
    );
  }
}

/// Picture size that fits the space: big on phones, smaller in landscape.
double _artSize(BoxConstraints c) => (c.maxHeight * 0.38).clamp(96.0, 200.0);

class _Art extends StatelessWidget {
  const _Art({
    required this.index,
    required this.controller,
    required this.illustration,
    required this.size,
  });

  final int index;
  final PageController controller;
  final KIllustration illustration;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: _Parallax(
      index: index,
      controller: controller,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: KIllustrationPainter(
            kind: illustration,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    ),
  );
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.index,
    required this.controller,
    required this.illustration,
    required this.title,
    required this.body,
  });

  final int index;
  final PageController controller;
  final KIllustration illustration;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: KSpacing.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _Art(
                index: index,
                controller: controller,
                illustration: illustration,
                size: _artSize(c),
              ),
              const SizedBox(height: KSpacing.xl),
              _Parallax(
                index: index,
                controller: controller,
                strength: 30,
                child: Column(
                  children: <Widget>[
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: KSpacing.md),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlacesPage extends StatelessWidget {
  const _PlacesPage({
    required this.index,
    required this.controller,
    required this.starters,
    required this.picked,
    required this.busy,
    required this.onToggle,
    required this.onUse,
    required this.onSkip,
  });

  final int index;
  final PageController controller;
  final List<StarterLocation> starters;
  final Set<int> picked;
  final bool busy;
  final void Function(int index) onToggle;
  final VoidCallback onUse;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: KSpacing.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _Art(
                index: index,
                controller: controller,
                illustration: KIllustration.emptyShelf,
                size: _artSize(c) * 0.7,
              ),
              const SizedBox(height: KSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  l10n.onboardingPlacesTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: KSpacing.sm),
              Text(
                l10n.onboardingPlacesBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: KSpacing.lg),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: KSpacing.sm,
                runSpacing: KSpacing.sm,
                children: <Widget>[
                  for (var i = 0; i < starters.length; i++)
                    FilterChip(
                      label: Text(starters[i].name),
                      // A tick when chosen, so the state never rests on colour.
                      avatar: Icon(
                        picked.contains(i)
                            ? Icons.check_rounded
                            : (starters[i].icon == 'box'
                                  ? Icons.inventory_2_outlined
                                  : Icons.shelves),
                        size: 18,
                      ),
                      showCheckmark: false,
                      selected: picked.contains(i),
                      onSelected: busy ? null : (_) => onToggle(i),
                    ),
                ],
              ),
              const SizedBox(height: KSpacing.xl),
              KButton(
                label: l10n.onboardingPlacesUse,
                expand: true,
                loading: busy,
                onPressed: busy ? null : onUse,
              ),
              TextButton(
                onPressed: busy ? null : onSkip,
                child: Text(l10n.onboardingPlacesSkip),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyPage extends StatelessWidget {
  const _ReadyPage({
    required this.index,
    required this.controller,
    required this.onAdd,
    required this.onRestore,
    required this.onExplore,
  });

  final int index;
  final PageController controller;
  final VoidCallback onAdd;
  final VoidCallback onRestore;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: KSpacing.xl),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: c.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _Art(
                index: index,
                controller: controller,
                illustration: KIllustration.openBook,
                size: _artSize(c) * 0.8,
              ),
              const SizedBox(height: KSpacing.lg),
              Semantics(
                header: true,
                child: Text(
                  l10n.onboardingReadyTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: KSpacing.sm),
              Text(
                l10n.onboardingReadyBody,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: KSpacing.xl),
              KButton(
                label: l10n.onboardingAddFirst,
                icon: Icons.add_rounded,
                expand: true,
                onPressed: onAdd,
              ),
              const SizedBox(height: KSpacing.md),
              KButton(
                label: l10n.onboardingRestore,
                icon: Icons.settings_backup_restore_rounded,
                variant: KButtonVariant.tonal,
                expand: true,
                onPressed: onRestore,
              ),
              TextButton(
                onPressed: onExplore,
                child: Text(l10n.onboardingExplore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page dots and the Next button.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.page,
    required this.pages,
    required this.onNext,
    required this.nextLabel,
    required this.stepLabel,
    required this.reduceMotion,
  });

  final int page;
  final int pages;
  final VoidCallback? onNext;
  final String nextLabel;
  final String stepLabel;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KSpacing.xl),
      child: Column(
        children: <Widget>[
          Semantics(
            label: stepLabel,
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (var i = 0; i < pages; i++)
                  AnimatedContainer(
                    duration: reduceMotion ? Duration.zero : KDurations.normal,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == page ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == page ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 64,
            child: onNext == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: KSpacing.md),
                    child: KButton(
                      label: nextLabel,
                      expand: true,
                      onPressed: onNext,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
