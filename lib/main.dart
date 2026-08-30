import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/dependency_injection.dart';

void main() {
  final appDependencies = AppDependencies.create();
  runApp(ZaiwanApp( dependencies: appDependencies));
}
