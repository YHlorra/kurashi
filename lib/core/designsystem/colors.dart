import 'package:flutter/material.dart';

/// 应用颜色常量 —— 翻译自 Web-Prototype CSS :root 变量
class AppColors {
  AppColors._();

  // 背景 / 表面
  static const Color bg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color surfaceWarm = Color(0xFFEEEEEE);

  // 前景
  static const Color fg = Color(0xFF111111);
  static const Color fg2 = Color(0xFF3A3A3A);
  static const Color muted = Color(0xFF707070);

  // 边框
  static const Color border = Color(0xFFD9D9D9);
  static const Color borderSoft = Color(0xFFEEEEEE);

  // 状态色
  static const Color success = Color(0xFF168A46);
  static const Color warn = Color(0xFFB7791F);
  static const Color danger = Color(0xFFC53030);

  // 状态色（柔和版）— 用于状态卡片背景
  static const Color successSoft = Color(0xFFEDF3EC);
  static const Color warnSoft = Color(0xFFFBF3DB);
  static const Color dangerSoft = Color(0xFFFDE2E2);
  static const Color dangerSoftAlt = Color(0xFFFDEBEC);

  // 暖色表面 — 用于临期提示卡等
  static const Color expiringBg = Color(0xFFFDF3E1);
  static const Color expiringBorder = Color(0xFFF5D9B0);

  // 阴影色
  static const Color shadow = Color(0x14000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowStrong = Color(0x33000000);

  // 分类色 — 冰箱食材 tag 状态
  static const Color catVegetable = Color(0xFFEDF3EC);
  static const Color catFruit = Color(0xFFFBF3DB);
  static const Color catMeat = Color(0xFFFDEBEC);

  // 其他
  static const Color white60 = Color(0x99FFFFFF);
  static const Color dangerBg = Color(0xFFB54141);
}
