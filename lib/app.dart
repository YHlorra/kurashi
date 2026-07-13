import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/designsystem/theme.dart';
import 'core/navigation/router.dart';

/// 应用根组件
class KurashiApp extends StatelessWidget {
  const KurashiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'kurashi',
      theme: appTheme(),
      routerConfig: appRouter,
      // 中文本地化 —— DatePicker / TimePicker 等系统组件中文文案依赖此配置
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
