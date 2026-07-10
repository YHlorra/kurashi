import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../feature/todo/screens/todo_screen.dart';
import '../../feature/subscription/screens/subscription_screen.dart';
import '../../feature/fridge/screens/fridge_screen.dart';
import '../designsystem/colors.dart';
import '../designsystem/app_icons.dart';

/// 全局路由配置 —— StatefulShellRoute.indexedStack 保留各 tab 状态
///
/// /splash 为冷启动首屏；停留 ~400ms 后 splash 自跳到 /todo。
/// 重新打开 app 不会回到 /splash（router 栈停在 /todo）。
final GoRouter appRouter = GoRouter(
  initialLocation: '/todo',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/todo',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TodoScreen(),
            ),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/subscription',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SubscriptionScreen(),
            ),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/fridge',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FridgeScreen(),
            ),
          ),
        ]),
      ],
    ),
  ],
);

/// 应用外壳：Scaffold + 自定义底部导航栏
class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTabSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

/// 自定义底部导航栏 —— 高 80px（含 safe area），白底，顶部分隔线
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68, // 68 + safe area padding (~12) ≈ 80
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                label: 'Todo',
                icon: AppIcons.todo(color: currentIndex == 0 ? AppColors.fg : AppColors.muted),
                isSelected: currentIndex == 0,
                onTap: () => onTabSelected(0),
              ),
              _NavItem(
                label: '订阅',
                icon: AppIcons.subscription(color: currentIndex == 1 ? AppColors.fg : AppColors.muted),
                isSelected: currentIndex == 1,
                onTap: () => onTabSelected(1),
              ),
              _NavItem(
                label: '冰箱',
                icon: AppIcons.fridge(color: currentIndex == 2 ? AppColors.fg : AppColors.muted),
                isSelected: currentIndex == 2,
                onTap: () => onTabSelected(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 单个导航按钮 —— 宽 96px，图标 24x24，文字 11px/500
class _NavItem extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.fg : AppColors.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
                letterSpacing: 0.02,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
