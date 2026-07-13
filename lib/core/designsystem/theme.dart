import 'package:flutter/material.dart';
import 'colors.dart';

/// 应用字体配置 —— bundle Inter + JetBrains Mono + Noto Sans SC，跨端像素级一致
/// 设计图原稿：Helvetica Neue（正文）+ SF Mono（等宽，用于计数/日期/周数）
/// 实际 bundle：Inter（Helvetica 开源近替，仅 Latin）+ JetBrains Mono（SF Mono 开源近替）
///           + Noto Sans SC（Inter 不含 CJK 字符时作为中文 fallback）
/// 字体文件随 app 打包，Android/iOS 两端渲染一致；fallback 仅为兜底
class AppFonts {
  AppFonts._();

  /// 正文 sans 字体 fallback 链
  /// Inter 仅 Latin；中文字符走 NotoSansSC（已 bundle，跨端一致）；
  /// 其余为系统兜底，仅在 bundle 字体加载失败时使用
  static const List<String> sansFallback = [
    'NotoSansSC', // 中文 fallback（已 bundle）
    'Helvetica Neue', // iOS 原生
    'PingFang SC', // macOS/iOS 中文
    'Microsoft YaHei', // Windows 中文
    'Roboto', // Android
    'Segoe UI',
    'Arial',
  ];
}

/// 全局 ThemeData —— Helvetica 单色调美学，非 Material 3 默认紫色
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.fg,
      onPrimary: AppColors.bg,
      surface: AppColors.surface,
      onSurface: AppColors.fg,
      error: AppColors.danger,
    ),
    // 字体：Inter（已 bundle）+ fallback 链（兜底，iOS/Windows/Android 系统字体）
    fontFamily: 'Inter',
    fontFamilyFallback: AppFonts.sansFallback,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.fg,
      ),
    ),
    // BottomSheet —— 圆角 24
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    // FAB —— 圆角 16
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.fg,
      foregroundColor: AppColors.bg,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
