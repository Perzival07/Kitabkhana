import 'package:flutter_test/flutter_test.dart';
import 'package:kitabkhana/core/failure.dart';

import '../../helpers/repo_harness.dart';

void main() {
  late RepoHarness h;

  setUp(() => h = RepoHarness());
  tearDown(() => h.dispose());

  test('setTarget creates then updates the same goal', () async {
    final a = (await h.goals.setTarget(2025, 24)).getOrNull()!;
    expect(a.year, 2025);
    expect(a.targetBooks, 24);
    expect(a.rev, 1);
    h.tick();
    final b = (await h.goals.setTarget(2025, 30)).getOrNull()!;
    expect(b.id, a.id);
    expect(b.targetBooks, 30);
    expect(b.rev, 2);
    expect(b.createdAt, a.createdAt);
    expect(b.updatedAt.isAfter(a.updatedAt), isTrue);
  });

  test('years are independent', () async {
    await h.goals.setTarget(2024, 10);
    await h.goals.setTarget(2025, 20);
    expect((await h.goals.getForYear(2024)).getOrNull()!.targetBooks, 10);
    expect((await h.goals.getForYear(2025)).getOrNull()!.targetBooks, 20);
    expect((await h.goals.getForYear(2026)).getOrNull(), isNull);
  });

  test('a non-positive target is a ValidationFailure', () async {
    for (final n in <int>[0, -3]) {
      expect(
        (await h.goals.setTarget(2025, n)).failureOrNull(),
        isA<ValidationFailure>(),
      );
    }
    expect((await h.goals.getForYear(2025)).getOrNull(), isNull);
  });

  test('clear removes the goal; setting again makes a new one', () async {
    final a = (await h.goals.setTarget(2025, 12)).getOrNull()!;
    expect((await h.goals.clear(2025)).isOk, isTrue);
    expect((await h.goals.getForYear(2025)).getOrNull(), isNull);
    expect((await h.goals.clear(2025)).failureOrNull(), isA<NotFoundFailure>());
    final b = (await h.goals.setTarget(2025, 15)).getOrNull()!;
    expect(b.id, isNot(a.id));
    expect(b.targetBooks, 15);
  });

  test('watchForYear is live', () async {
    final seen = <int?>[];
    final sub = h.goals
        .watchForYear(2025)
        .listen((g) => seen.add(g?.targetBooks));
    await pumpEventQueue();
    await h.goals.setTarget(2025, 10);
    await pumpEventQueue();
    await h.goals.setTarget(2025, 12);
    await pumpEventQueue();
    await h.goals.clear(2025);
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [null, 10, 12, null]);
  });
}
