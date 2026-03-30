import 'package:flutter/material.dart';

/// 자유 입력 필드(할 일, 이름 등): 한·영·숫자·이모지는 OS/IME·기본 [TextField]에 맡긴다.
/// ASCII만 허용하는 [FilteringTextInputFormatter] 등을 붙이지 않는다.
abstract final class AppTextInput {
  AppTextInput._();

  static const TextInputType keyboard = TextInputType.text;
}
