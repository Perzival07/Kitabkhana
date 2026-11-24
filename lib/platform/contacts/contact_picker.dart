import 'package:flutter/foundation.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';

/// A person chosen from the phone's contacts.
typedef PickedContact = ({String name, String? phone});

/// Opens the system contact picker. The app gets only the one contact the
/// reader taps, so no contacts permission is needed or asked for.
abstract interface class ContactPicker {
  /// False where there is no system picker (the web).
  bool get supported;

  /// The chosen contact, or null when cancelled.
  Future<PickedContact?> pick();
}

class SystemContactPicker implements ContactPicker {
  const SystemContactPicker();

  @override
  bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<PickedContact?> pick() async {
    try {
      final c = await FlutterNativeContactPicker().selectPhoneNumber();
      if (c == null) return null;
      final name = c.fullName?.trim() ?? '';
      final phone = c.selectedPhoneNumber?.trim().isNotEmpty ?? false
          ? c.selectedPhoneNumber!.trim()
          : c.phoneNumbers?.where((p) => p.trim().isNotEmpty).firstOrNull;
      if (name.isEmpty && phone == null) return null;
      return (name: name, phone: phone);
    } on Object {
      return null;
    }
  }
}
