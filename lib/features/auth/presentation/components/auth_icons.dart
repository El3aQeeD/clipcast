import 'package:flutter/widgets.dart';

class AuthIcons {
  AuthIcons._();

  static const _kFontFam = 'BatchOneIconAuth';
  static const String? _kFontPkg = null;

  static const IconData favCategoryUnselected =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData favCategorySelected =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData unlockPro =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData featureUnlock =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData correctCheckMark =
      IconData(0xe805, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData removeRedEye =
      IconData(0xe806, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData checkYourEmail =
      IconData(0xe807, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData appleIcon =
      IconData(0xe808, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData google =
      IconData(0xe809, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData mail =
      IconData(0xe80a, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData backIcon =
      IconData(0xe80b, fontFamily: _kFontFam, fontPackage: _kFontPkg);

  // Separate font for the OTP email icon (properly centered)
  static const IconData otpEmailIcon =
      IconData(0xe800, fontFamily: 'OtpEmailIcon');
}
