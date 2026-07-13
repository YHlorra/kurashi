import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/designsystem/app_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../data/repositories/fridge_repository.dart';
import '../../../data/repositories/providers.dart';

/// 购物清单 —— 小票视觉
///
/// 数据来源：`FridgeRepository.getRestockCandidates()` 按 name 聚合
/// 视觉：暖米白纸 + 撕边虚线 + mono 字体 + 黑色印章
class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidatesAsync = ref.watch(_restockCandidatesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        toolbarHeight: 52,
        title: const Text(
          '购物清单',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.44,
            color: AppColors.fg,
          ),
        ),
        actions: [
          IconButton(
            icon: AppIcons.share(size: 22, color: AppColors.fg),
            tooltip: '分享清单',
            onPressed: candidatesAsync.maybeWhen(
              data: (c) => c.isEmpty ? null : () => _share(context, c),
              orElse: () => null,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: candidatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            '加载失败：$e',
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
        data: (candidates) {
          if (candidates.isEmpty) {
            return const _EmptyState();
          }
          return _ReceiptView(candidates: candidates);
        },
      ),
    );
  }

  Future<void> _share(
    BuildContext context,
    List<RestockCandidate> candidates,
  ) async {
    final buf = StringBuffer()
      ..writeln('kurashi · 购物清单')
      ..writeln('——————')
      ..writeln(_dateStr())
      ..writeln('');
    for (final c in candidates) {
      buf.writeln('${c.name} × ${c.restockQty}');
    }
    buf
      ..writeln('')
      ..writeln('——————')
      ..writeln('共 ${candidates.length} 项');
    try {
      await Share.share(buf.toString(), subject: 'kurashi 购物清单');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败：$e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _dateStr() {
    final now = DateTime.now();
    return '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  }
}

/// 局部 FutureProvider —— 跟随 fridgeRepositoryProvider 实例，自动跟随 widget 树释放。
final _restockCandidatesProvider =
    FutureProvider.autoDispose<List<RestockCandidate>>((ref) async {
      final repo = ref.watch(fridgeRepositoryProvider);
      return repo.getRestockCandidates();
    });

/// 空状态 —— 无任何补货候选时
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.receipt_long, size: 24, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无补货项',
            style: TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          const Text(
            '食材充足，无需购物',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// 小票视图
class _ReceiptView extends StatefulWidget {
  final List<RestockCandidate> candidates;

  const _ReceiptView({required this.candidates});

  @override
  State<_ReceiptView> createState() => _ReceiptViewState();
}

class _ReceiptViewState extends State<_ReceiptView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // 小票纸面配色 —— 与 AppColors 主色板不同，仅此屏使用
  static const _paperTop = Color(0xFFFFF8E7);
  static const _paperBottom = Color(0xFFFBF1D8);
  static const _ink = Color(0xFF17130C);
  static const _inkSoft = Color(0xFF4B412F);
  static const _serialMuted = Color(0xFF6D6045);

  @override
  void initState() {
    super.initState();
    final durationMs = widget.candidates.length * 120 + 320;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidates = widget.candidates;
    final generatedAt = _nowStr();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_paperTop, _paperBottom],
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TearEdge(
              color: _ink,
              dashWidth: 8,
              dashGap: 4,
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kicker
                  const Text(
                    'KURASHI PANTRY',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2.4,
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.w700,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 标题
                  const Text(
                    '购物清单',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: _ink,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                      decorationColor: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 编号
                  Text(
                    'FRIDGE RESTOCK RECEIPT\nNO. ${_serialNo()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.7,
                      color: _inkSoft,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _Rule(thickness: 2, color: _ink),
                  const SizedBox(height: 8),
                  // 商品列表
                  for (int i = 0; i < candidates.length; i++)
                    _ReceiptRow(
                      candidate: candidates[i],
                      animation: _controller,
                      intervalStart:
                          (i * 120) / (candidates.length * 120 + 320),
                    ),
                  const SizedBox(height: 10),
                  const _Rule(thickness: 1, color: _ink),
                  const SizedBox(height: 14),
                  _TotalBlock(candidates: candidates),
                  const SizedBox(height: 16),
                  Text(
                    '生成时间 $generatedAt\n本清单来自 kurashi 冰箱',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.7,
                      color: _inkSoft,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '—— 完 ——',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                      color: _ink,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'THANK YOU / BUY ONLY WHAT YOU NEED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.8,
                      color: _serialMuted,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ],
              ),
            ),
            const _TearEdge(
              color: _ink,
              dashWidth: 8,
              dashGap: 4,
              thickness: 2,
            ),
          ],
        ),
      ),
    );
  }

  String _nowStr() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}-${two(now.month)}-${two(now.day)} ${two(now.hour)}:${two(now.minute)}';
  }

  String _serialNo() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(now.month)}${two(now.day)}-${two(now.hour)}${two(now.minute)}';
  }
}

/// 小票单行 —— name + qty × + 「需补货」印章
class _ReceiptRow extends StatelessWidget {
  final RestockCandidate candidate;
  final AnimationController animation;
  final double intervalStart;

  const _ReceiptRow({
    required this.candidate,
    required this.animation,
    required this.intervalStart,
  });

  static const _ink = Color(0xFF17130C);

  @override
  Widget build(BuildContext context) {
    final interval = Interval(
      intervalStart,
      intervalStart + 320 / (animation.duration!.inMilliseconds),
      curve: Curves.easeOut,
    );
    final curved = CurvedAnimation(parent: animation, curve: interval);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _ink, width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  candidate.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: _ink,
                    fontFamily: 'JetBrainsMono',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '× ${candidate.restockQty}',
                style: const TextStyle(
                  fontSize: 13,
                  color: _ink,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Text(
                  '需补货',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: _ReceiptViewState._paperTop,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 总计块 —— 总计 / 需补货 / 多批次
class _TotalBlock extends StatelessWidget {
  final List<RestockCandidate> candidates;

  const _TotalBlock({required this.candidates});

  // 与外层 _ReceiptView 一致
  static const _ink = Color(0xFF17130C);

  @override
  Widget build(BuildContext context) {
    final multiBatch = candidates.where((c) => c.batches.length > 1).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _totalRow('总计', '${candidates.length} 项'),
        _totalRow('需补货', '${candidates.length} 项'),
        _totalRow('多批次', '$multiBatch 项'),
      ],
    );
  }

  Widget _totalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _ink,
              fontFamily: 'JetBrainsMono',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _ink,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }
}

/// 小票水平分隔线（实线）
class _Rule extends StatelessWidget {
  final double thickness;
  final Color color;

  const _Rule({required this.thickness, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(height: thickness, color: color);
  }
}

/// 小票撕边虚线 —— CustomPainter 绘制短横线
///
/// ponytail: 用 CustomPaint 而非 dash border（Flutter BoxBorder 不支持 dash），
/// 高度 8dp 容纳 2dp 虚线 + 上下间距。
class _TearEdge extends StatelessWidget {
  final Color color;
  final double dashWidth;
  final double dashGap;
  final double thickness;

  const _TearEdge({
    required this.color,
    this.dashWidth = 8,
    this.dashGap = 4,
    this.thickness = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: thickness + 4,
      child: CustomPaint(
        size: Size.infinite,
        painter: _DashedLinePainter(
          color: color,
          thickness: thickness,
          dashWidth: dashWidth,
          gap: dashGap,
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double thickness;
  final double dashWidth;
  final double gap;

  _DashedLinePainter({
    required this.color,
    required this.thickness,
    required this.dashWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;
    final y = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final end = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter old) =>
      old.color != color ||
      old.thickness != thickness ||
      old.dashWidth != dashWidth ||
      old.gap != gap;
}
