import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localisations.dart';

class Strings {
  static AppLocalisations of(BuildContext context) => Localizations.of<AppLocalisations>(context, AppLocalisations)!;
}
