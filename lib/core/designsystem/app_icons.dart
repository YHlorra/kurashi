import 'package:flutter/material.dart';
import 'package:flutter_icon_park/flutter_icon_park.dart';

import 'colors.dart';

/// 全局图标命名空间 —— 语义名 → IconPark outline 图标
///
/// 统一替代 Material Icons (`Icons.xxx`) + 手写 SVG path 绘制器。
/// 所有图标默认 strokeWidth=2.0，使用 outline 主题，与 Web-Prototype 设计稿一致。
///
/// IconPark outline API: `IconPark.xxx.outline(fill: color, size: 24, strokeWidth: 2)`
class AppIcons {
  AppIcons._();

  // ─── 导航栏 ──────────────────────────────────────────

  /// Todo tab —— 圆圈内对勾
  static Widget todo({Color? color, double size = 24}) =>
      IconPark.checkOne.outline(fill: color, size: size, strokeWidth: 2);

  /// Subscription tab —— 小票/账单
  static Widget subscription({Color? color, double size = 24}) =>
      IconPark.bill.outline(fill: color, size: size, strokeWidth: 2);

  /// Fridge tab —— 储物盒（IconPark 无冰箱图标，box 近似）
  static Widget fridge({Color? color, double size = 24}) =>
      IconPark.box.outline(fill: color, size: size, strokeWidth: 2);

  // ─── FAB ─────────────────────────────────────────────

  /// 加号 FAB
  static Widget add({Color? color, double size = 24}) => CustomPaint(
    size: Size(size, size),
    painter: _PlusPainter(color ?? AppColors.fg),
  );

  // ─── 通用操作 ────────────────────────────────────────

  /// 更多（三点横线 / 汉堡按钮）
  static Widget more({Color? color, double size = 24}) =>
      IconPark.moreApp.outline(fill: color, size: size, strokeWidth: 2);

  /// 关闭 X
  static Widget close({Color? color, double size = 18}) =>
      IconPark.close.outline(fill: color, size: size, strokeWidth: 2);

  /// 设置 / 筛选
  static Widget setting({Color? color, double size = 22}) =>
      IconPark.settingOne.outline(fill: color, size: size, strokeWidth: 2);

  /// 分享 / 导出
  static Widget share({Color? color, double size = 22}) =>
      IconPark.shareTwo.outline(fill: color, size: size, strokeWidth: 2);

  /// 历史记录
  static Widget history({Color? color, double size = 22}) =>
      IconPark.history.outline(fill: color, size: size, strokeWidth: 2);

  /// 右箭头 / 返回
  static Widget right({Color? color, double size = 16}) =>
      IconPark.rightC.outline(fill: color, size: size, strokeWidth: 2);

  /// 左向 chevron —— AppBar leading 返回（语义与 right 相反）
  static Widget left({Color? color, double size = 16}) =>
      IconPark.leftC.outline(fill: color, size: size, strokeWidth: 2);

  /// 选中对勾（小号）
  static Widget check({Color? color, double size = 14}) =>
      IconPark.checkSmall.outline(fill: color, size: size, strokeWidth: 2);

  // ─── 订阅分类图标 ────────────────────────────────────

  /// 中国节日（星）
  static Widget cnFestival({Color? color, double size = 24}) =>
      IconPark.star.outline(fill: color, size: size, strokeWidth: 2);

  /// 西方节日（日历）
  static Widget westernFestival({Color? color, double size = 24}) =>
      IconPark.calendarThree.outline(fill: color, size: size, strokeWidth: 2);

  /// 家居维护
  static Widget home({Color? color, double size = 24}) =>
      IconPark.home.outline(fill: color, size: size, strokeWidth: 2);

  /// 宠物
  static Widget pet({Color? color, double size = 24}) =>
      IconPark.dog.outline(fill: color, size: size, strokeWidth: 2);

  /// 证件（文档详情）
  static Widget document({Color? color, double size = 24}) =>
      IconPark.docDetail.outline(fill: color, size: size, strokeWidth: 2);

  /// 健康
  static Widget health({Color? color, double size = 24}) =>
      IconPark.health.outline(fill: color, size: size, strokeWidth: 2);

  /// 车辆
  static Widget vehicle({Color? color, double size = 24}) =>
      IconPark.car.outline(fill: color, size: size, strokeWidth: 2);

  /// 生日 / 纪念日（蛋糕）
  static Widget birthday({Color? color, double size = 24}) =>
      IconPark.cakeFour.outline(fill: color, size: size, strokeWidth: 2);

  /// 还款 / 信用卡
  static Widget bill({Color? color, double size = 24}) =>
      IconPark.credit.outline(fill: color, size: size, strokeWidth: 2);

  /// 自定义（加号）
  static Widget custom({Color? color, double size = 24}) =>
      IconPark.add.outline(fill: color, size: size, strokeWidth: 2);

  // ─── 冰箱历史操作元数据 ──────────────────────────────

  /// 新增操作色标图标（加号）
  static Widget actionAdd({Color? color, double size = 16}) =>
      IconPark.addOne.outline(fill: color, size: size, strokeWidth: 2);

  /// 修改操作色标图标（铅笔）
  static Widget actionEdit({Color? color, double size = 16}) =>
      IconPark.edit.outline(fill: color, size: size, strokeWidth: 2);

  /// 删除操作色标图标（垃圾桶）
  static Widget actionDelete({Color? color, double size = 16}) =>
      IconPark.deleteOne.outline(fill: color, size: size, strokeWidth: 2);

  /// 恢复操作色标图标（刷新箭头）
  static Widget actionRestore({Color? color, double size = 16}) =>
      IconPark.refresh.outline(fill: color, size: size, strokeWidth: 2);

  // ─── 家居维护预设图标（HomeSheet 12 项常用项） ──────────
  //
  // IconPark 无牙刷/枕头等细分类目，用语义最接近的替代：barberBrush = 刷子类
  // 双线轮廓；doubleBed = 床；sleep = 月亮（寝具语义）；fire = 火苗（烟雾报警）。

  /// 牙刷 / 电动牙刷头（刷子类，无更专的图标）
  static Widget brush({Color? color, double size = 24}) =>
      IconPark.barberBrush.outline(fill: color, size: size, strokeWidth: 2);

  /// 空气净化器滤芯（风）
  static Widget wind({Color? color, double size = 24}) =>
      IconPark.wind.outline(fill: color, size: size, strokeWidth: 2);

  /// 净水器滤芯（水滴）
  static Widget water({Color? color, double size = 24}) =>
      IconPark.water.outline(fill: color, size: size, strokeWidth: 2);

  /// 空调滤芯
  static Widget airConditioning({Color? color, double size = 24}) =>
      IconPark.airConditioning.outline(fill: color, size: size, strokeWidth: 2);

  /// 油烟机滤网（锅）
  static Widget cook({Color? color, double size = 24}) =>
      IconPark.cook.outline(fill: color, size: size, strokeWidth: 2);

  /// 洗衣机滤网
  static Widget washingMachine({Color? color, double size = 24}) =>
      IconPark.washingMachine.outline(fill: color, size: size, strokeWidth: 2);

  /// 淋浴头（浴缸代）
  static Widget shower({Color? color, double size = 24}) =>
      IconPark.tub.outline(fill: color, size: size, strokeWidth: 2);

  /// 枕头（睡眠/月）
  static Widget sleep({Color? color, double size = 24}) =>
      IconPark.sleep.outline(fill: color, size: size, strokeWidth: 2);

  /// 床垫
  static Widget bed({Color? color, double size = 24}) =>
      IconPark.doubleBed.outline(fill: color, size: size, strokeWidth: 2);

  /// 烟雾报警器（火）
  static Widget fire({Color? color, double size = 24}) =>
      IconPark.fire.outline(fill: color, size: size, strokeWidth: 2);

  /// 灭火器
  static Widget fireExtinguisher({Color? color, double size = 24}) => IconPark
      .fireExtinguisher
      .outline(fill: color, size: size, strokeWidth: 2);

  // ─── 订阅 preset 通用图标（PetSheet / DocumentSheet / HealthSheet / VehicleSheet） ───
  //
  // IconPark 无具体图标时取语义最接近的：bear≈仓鼠(小型哺乳动物)，
  // handCream≈皮肤/护肤，brakePads≈刹车，recordDisc≈轮胎（圆盘），
  // certificate≈证件/证明，shield≈保险保障。

  // ─── PetSheet ───
  static Widget cat({Color? color, double size = 24}) =>
      IconPark.cat.outline(fill: color, size: size, strokeWidth: 2);
  static Widget rabbit({Color? color, double size = 24}) =>
      IconPark.rabbit.outline(fill: color, size: size, strokeWidth: 2);

  /// 仓鼠：无 hamster 图标，用小型哺乳动物代
  static Widget bear({Color? color, double size = 24}) =>
      IconPark.bear.outline(fill: color, size: size, strokeWidth: 2);
  static Widget bird({Color? color, double size = 24}) =>
      IconPark.bird.outline(fill: color, size: size, strokeWidth: 2);

  /// 狂犬疫苗 / 核心疫苗 / 各类疫苗：IconPark 无 syringe，用注射器代
  static Widget injection({Color? color, double size = 24}) =>
      IconPark.injection.outline(fill: color, size: size, strokeWidth: 2);

  /// 心丝虫
  static Widget heart({Color? color, double size = 24}) =>
      IconPark.heart.outline(fill: color, size: size, strokeWidth: 2);

  /// 跳蚤蜱虫
  static Widget bug({Color? color, double size = 24}) =>
      IconPark.bug.outline(fill: color, size: size, strokeWidth: 2);

  /// 体内驱虫 / 体外驱虫：防护语义
  static Widget protect({Color? color, double size = 24}) =>
      IconPark.protect.outline(fill: color, size: size, strokeWidth: 2);

  /// 体检 / 全身体检
  static Widget stethoscope({Color? color, double size = 24}) =>
      IconPark.stethoscope.outline(fill: color, size: size, strokeWidth: 2);

  /// 牙科
  static Widget teeth({Color? color, double size = 24}) =>
      IconPark.teeth.outline(fill: color, size: size, strokeWidth: 2);

  /// 剪指甲
  static Widget scissors({Color? color, double size = 24}) =>
      IconPark.scissors.outline(fill: color, size: size, strokeWidth: 2);

  // ─── DocumentSheet ───
  /// 身份证（横版）
  static Widget idCardH({Color? color, double size = 24}) =>
      IconPark.idCardH.outline(fill: color, size: size, strokeWidth: 2);

  /// 护照
  static Widget passport({Color? color, double size = 24}) =>
      IconPark.passport.outline(fill: color, size: size, strokeWidth: 2);

  /// 通用证件 / 驾驶证 / 年检：IconPark 无 drivingLicense，用通用证书代
  static Widget certificate({Color? color, double size = 24}) =>
      IconPark.certificate.outline(fill: color, size: size, strokeWidth: 2);

  /// 行驶证（竖版身份证式）
  static Widget idCardV({Color? color, double size = 24}) =>
      IconPark.idCardV.outline(fill: color, size: size, strokeWidth: 2);

  /// 港澳通行证
  static Widget passportOne({Color? color, double size = 24}) =>
      IconPark.passportOne.outline(fill: color, size: size, strokeWidth: 2);

  /// 居住证
  static Widget idCard({Color? color, double size = 24}) =>
      IconPark.idCard.outline(fill: color, size: size, strokeWidth: 2);

  /// 社保卡（银行卡类）
  static Widget bankCard({Color? color, double size = 24}) =>
      IconPark.bankCard.outline(fill: color, size: size, strokeWidth: 2);

  /// 医保卡
  static Widget medicalFiles({Color? color, double size = 24}) =>
      IconPark.medicalFiles.outline(fill: color, size: size, strokeWidth: 2);

  /// 会员卡
  static Widget vip({Color? color, double size = 24}) =>
      IconPark.vip.outline(fill: color, size: size, strokeWidth: 2);

  // ─── HealthSheet ───
  /// 眼科
  static Widget eyes({Color? color, double size = 24}) =>
      IconPark.eyes.outline(fill: color, size: size, strokeWidth: 2);

  /// 妇科男科 / 妇科检查（多人代）
  static Widget peoples({Color? color, double size = 24}) =>
      IconPark.peoples.outline(fill: color, size: size, strokeWidth: 2);

  /// 影像筛查
  static Widget scan({Color? color, double size = 24}) =>
      IconPark.scan.outline(fill: color, size: size, strokeWidth: 2);

  /// 慢病复查 / 血压监测（心率图标代）
  static Widget heartRate({Color? color, double size = 24}) =>
      IconPark.heartRate.outline(fill: color, size: size, strokeWidth: 2);

  /// 乳腺/宫颈/前列腺/骨密度筛查（通用体检盒代）
  static Widget medicalBox({Color? color, double size = 24}) =>
      IconPark.medicalBox.outline(fill: color, size: size, strokeWidth: 2);

  /// 血糖 / 血脂（心电图代）
  static Widget electrocardiogram({Color? color, double size = 24}) => IconPark
      .electrocardiogram
      .outline(fill: color, size: size, strokeWidth: 2);

  /// 皮肤（护肤代）
  static Widget handCream({Color? color, double size = 24}) =>
      IconPark.handCream.outline(fill: color, size: size, strokeWidth: 2);

  // ─── VehicleSheet ───
  /// 机油 / 各类油液（IconPark petrol）
  static Widget petrol({Color? color, double size = 24}) =>
      IconPark.petrol.outline(fill: color, size: size, strokeWidth: 2);

  /// 滤芯（通用 filter 图标）
  static Widget filter({Color? color, double size = 24}) =>
      IconPark.filter.outline(fill: color, size: size, strokeWidth: 2);

  /// 刹车片 / 刹车
  static Widget brakePads({Color? color, double size = 24}) =>
      IconPark.brakePads.outline(fill: color, size: size, strokeWidth: 2);

  /// 轮胎（圆盘代，IconPark 无 tire）
  static Widget recordDisc({Color? color, double size = 24}) =>
      IconPark.recordDisc.outline(fill: color, size: size, strokeWidth: 2);

  /// 电瓶
  static Widget carBattery({Color? color, double size = 24}) =>
      IconPark.carBattery.outline(fill: color, size: size, strokeWidth: 2);

  /// 车身打蜡 / 外观
  static Widget paint({Color? color, double size = 24}) =>
      IconPark.paint.outline(fill: color, size: size, strokeWidth: 2);

  /// 火花塞（电波代）
  static Widget electricWave({Color? color, double size = 24}) =>
      IconPark.electricWave.outline(fill: color, size: size, strokeWidth: 2);

  /// 内饰清洁
  static Widget vacuumCleaner({Color? color, double size = 24}) =>
      IconPark.vacuumCleaner.outline(fill: color, size: size, strokeWidth: 2);

  /// 交强险 / 商业险（盾代保险）
  static Widget shield({Color? color, double size = 24}) =>
      IconPark.shield.outline(fill: color, size: size, strokeWidth: 2);
}

class _PlusPainter extends CustomPainter {
  final Color color;
  _PlusPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(12, 5)
      ..lineTo(12, 19)
      ..moveTo(5, 12)
      ..lineTo(19, 12);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PlusPainter oldDelegate) =>
      oldDelegate.color != color;
}
