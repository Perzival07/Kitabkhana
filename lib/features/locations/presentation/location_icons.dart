import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Icon keys a location can store, in picker order.
const List<String> kLocationIconKeys = <String>[
  'shelf',
  'box',
  'room',
  'bag',
  'office',
  'other',
];

IconData locationIcon(String? key) => switch (key) {
  'shelf' => Icons.shelves,
  'box' => Icons.inventory_2_outlined,
  'room' => Icons.meeting_room_outlined,
  'bag' => Icons.shopping_bag_outlined,
  'office' => Icons.business_center_outlined,
  _ => Icons.place_outlined,
};

String locationIconLabel(AppLocalizations l10n, String key) => switch (key) {
  'shelf' => l10n.locationIconShelf,
  'box' => l10n.locationIconBox,
  'room' => l10n.locationIconRoom,
  'bag' => l10n.locationIconBag,
  'office' => l10n.locationIconOffice,
  _ => l10n.locationIconOther,
};
