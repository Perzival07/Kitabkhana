import 'package:kitabkhana/platform/contacts/contact_picker.dart';

/// Hands back [next] instead of opening the phone's contacts.
class FakeContactPicker implements ContactPicker {
  FakeContactPicker({this.supported = true, this.next});

  @override
  final bool supported;
  PickedContact? next;
  int asked = 0;

  @override
  Future<PickedContact?> pick() async {
    asked++;
    return next;
  }
}
