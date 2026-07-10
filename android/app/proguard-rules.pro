# Flutter app ProGuard / R8 keep rules.
# 闪退根因（2026-07-09）：androidx.work.impl.WorkDatabase_Impl.<init> 在 R8 后丢失默认构造器。
# flutter workmanager 0.9.x 插件的反射入口未被 Flutter 默认 R8 规则覆盖。

# === androidx.work (workmanager plugin 底层) ===
# 反射入口：WorkDatabase_Impl.<init>、WorkProgressUpdater 等
-keep class androidx.work.impl.WorkDatabase { *; }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.WorkProgressUpdater { *; }
-keep class androidx.work.impl.WorkContinuationImpl { *; }
-keep class androidx.work.impl.background.systemalarm.** { *; }
-keep class androidx.work.impl.background.systemjob.** { *; }
-keep class androidx.work.impl.background.greedy.** { *; }
-keep class androidx.work.WorkManagerInitializer { *; }

# === androidx.startup (ContentProvider 自动初始化入口) ===
-keep class androidx.startup.InitializationProvider { *; }
-keep class * extends androidx.startup.Initializer { *; }