// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_name": MessageLookupByLibrary.simpleMessage("Gold Emperor"),
        "dialog_default_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "dialog_default_confirm":
            MessageLookupByLibrary.simpleMessage("Confirm"),
        "dialog_default_got_it": MessageLookupByLibrary.simpleMessage("Got it"),
        "dialog_default_tip_loading":
            MessageLookupByLibrary.simpleMessage("Loading..."),
        "dialog_default_title_error":
            MessageLookupByLibrary.simpleMessage("Error"),
        "dialog_default_title_information":
            MessageLookupByLibrary.simpleMessage("Tips"),
        "face_login_failed": MessageLookupByLibrary.simpleMessage(
            "Failed to start facial recognition"),
        "face_login_get_photo_path_failed":
            MessageLookupByLibrary.simpleMessage(
                "Get photo information failed"),
        "face_login_getting_photo_path": MessageLookupByLibrary.simpleMessage(
            "Getting photo information..."),
        "face_login_no_camera_permission":
            MessageLookupByLibrary.simpleMessage("No camera permissions"),
        "get_verify_code": MessageLookupByLibrary.simpleMessage("Get verify"),
        "language": MessageLookupByLibrary.simpleMessage("Language:"),
        "logging": MessageLookupByLibrary.simpleMessage("Logging..."),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "login_failed": MessageLookupByLibrary.simpleMessage("Login failed"),
        "login_hint_password": MessageLookupByLibrary.simpleMessage("Password"),
        "login_hint_phone":
            MessageLookupByLibrary.simpleMessage("Phone number"),
        "login_hint_verify_code":
            MessageLookupByLibrary.simpleMessage("verify code"),
        "login_tips_password":
            MessageLookupByLibrary.simpleMessage("Please enter your password"),
        "login_tips_phone": MessageLookupByLibrary.simpleMessage(
            "Please enter your phone number"),
        "login_tips_verify_code": MessageLookupByLibrary.simpleMessage(
            "Please enter your verify code"),
        "phone_login_get_verify_code_failed":
            MessageLookupByLibrary.simpleMessage("Verify code sending failed"),
        "phone_login_get_verify_code_success":
            MessageLookupByLibrary.simpleMessage(
                "Verify code sent successfully"),
        "phone_login_getting_verify_code":
            MessageLookupByLibrary.simpleMessage("Sending verify code...")
      };
}
