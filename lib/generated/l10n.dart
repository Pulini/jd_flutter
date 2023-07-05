// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Gold Emperor`
  String get app_name {
    return Intl.message(
      'Gold Emperor',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get key_board_done {
    return Intl.message(
      'Done',
      name: 'key_board_done',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get dialog_default_title_information {
    return Intl.message(
      'Tips',
      name: 'dialog_default_title_information',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get dialog_default_title_error {
    return Intl.message(
      'Error',
      name: 'dialog_default_title_error',
      desc: '',
      args: [],
    );
  }

  /// `Loading...`
  String get dialog_default_tip_loading {
    return Intl.message(
      'Loading...',
      name: 'dialog_default_tip_loading',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get dialog_default_confirm {
    return Intl.message(
      'Confirm',
      name: 'dialog_default_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get dialog_default_got_it {
    return Intl.message(
      'Got it',
      name: 'dialog_default_got_it',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get dialog_default_cancel {
    return Intl.message(
      'Cancel',
      name: 'dialog_default_cancel',
      desc: '',
      args: [],
    );
  }

  /// `Language:`
  String get language {
    return Intl.message(
      'Language:',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get login_hint_phone {
    return Intl.message(
      'Phone number',
      name: 'login_hint_phone',
      desc: '',
      args: [],
    );
  }

  /// `Machine number`
  String get login_hint_machine {
    return Intl.message(
      'Machine number',
      name: 'login_hint_machine',
      desc: '',
      args: [],
    );
  }

  /// `Work number`
  String get login_hint_work_number {
    return Intl.message(
      'Work number',
      name: 'login_hint_work_number',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get login_hint_password {
    return Intl.message(
      'Password',
      name: 'login_hint_password',
      desc: '',
      args: [],
    );
  }

  /// `verify code`
  String get login_hint_verify_code {
    return Intl.message(
      'verify code',
      name: 'login_hint_verify_code',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number`
  String get login_tips_phone {
    return Intl.message(
      'Please enter your phone number',
      name: 'login_tips_phone',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the machine account`
  String get login_tips_machine {
    return Intl.message(
      'Please enter the machine account',
      name: 'login_tips_machine',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the work number`
  String get login_tips_work_number {
    return Intl.message(
      'Please enter the work number',
      name: 'login_tips_work_number',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your password`
  String get login_tips_password {
    return Intl.message(
      'Please enter your password',
      name: 'login_tips_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your verify code`
  String get login_tips_verify_code {
    return Intl.message(
      'Please enter your verify code',
      name: 'login_tips_verify_code',
      desc: '',
      args: [],
    );
  }

  /// `Get verify`
  String get get_verify_code {
    return Intl.message(
      'Get verify',
      name: 'get_verify_code',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get login {
    return Intl.message(
      'Login',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Logging...`
  String get logging {
    return Intl.message(
      'Logging...',
      name: 'logging',
      desc: '',
      args: [],
    );
  }

  /// `Login failed`
  String get login_failed {
    return Intl.message(
      'Login failed',
      name: 'login_failed',
      desc: '',
      args: [],
    );
  }

  /// `Sending verify code...`
  String get phone_login_getting_verify_code {
    return Intl.message(
      'Sending verify code...',
      name: 'phone_login_getting_verify_code',
      desc: '',
      args: [],
    );
  }

  /// `Verify code sent successfully`
  String get phone_login_get_verify_code_success {
    return Intl.message(
      'Verify code sent successfully',
      name: 'phone_login_get_verify_code_success',
      desc: '',
      args: [],
    );
  }

  /// `Verify code sending failed`
  String get phone_login_get_verify_code_failed {
    return Intl.message(
      'Verify code sending failed',
      name: 'phone_login_get_verify_code_failed',
      desc: '',
      args: [],
    );
  }

  /// `No camera permissions`
  String get face_login_no_camera_permission {
    return Intl.message(
      'No camera permissions',
      name: 'face_login_no_camera_permission',
      desc: '',
      args: [],
    );
  }

  /// `Failed to start facial recognition`
  String get face_login_failed {
    return Intl.message(
      'Failed to start facial recognition',
      name: 'face_login_failed',
      desc: '',
      args: [],
    );
  }

  /// `Getting photo information...`
  String get face_login_getting_photo_path {
    return Intl.message(
      'Getting photo information...',
      name: 'face_login_getting_photo_path',
      desc: '',
      args: [],
    );
  }

  /// `Get photo information failed`
  String get face_login_get_photo_path_failed {
    return Intl.message(
      'Get photo information failed',
      name: 'face_login_get_photo_path_failed',
      desc: '',
      args: [],
    );
  }

  /// `Produce`
  String get home_bottom_bar_produce {
    return Intl.message(
      'Produce',
      name: 'home_bottom_bar_produce',
      desc: '',
      args: [],
    );
  }

  /// `Warehouse`
  String get home_bottom_bar_warehouse {
    return Intl.message(
      'Warehouse',
      name: 'home_bottom_bar_warehouse',
      desc: '',
      args: [],
    );
  }

  /// `Manage`
  String get home_bottom_bar_manage {
    return Intl.message(
      'Manage',
      name: 'home_bottom_bar_manage',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
