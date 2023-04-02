import 'package:flutter/material.dart';

import '../components/shaking.dart';

abstract class WordleListener {
  void onLoginSuccess();
  void onLoginError(String errorMessage);
}

class WordleController {
  final shakeKey = GlobalKey<ShakeWidgetState>();
  final focusNode = FocusNode();

  int currentWordIndex = 0;
}
