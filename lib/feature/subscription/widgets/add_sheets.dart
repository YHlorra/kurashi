import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/app_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../core/designsystem/fields.dart';
import '../../../core/designsystem/segmented.dart';
import '../../../data/models/subscription.dart';
import 'sheet_scaffold.dart';

// ── 共享辅助 ────────────────────────────────────────────────────────────

/// 把新订阅写入仓库并调度提醒；sheet 内 9 个表单共用。
/// 返回 0（调用方不消费 id）。
Future<int> _addSub(WidgetRef ref, Subscription sub) async {
  await submitSub(ref, sub);
  return 0;
}

/// 「cycle」间隔选项（按 intervalDays）—— 5 个新 sheet 共用同一组枚举。
const _cycleOptions = <int>[30, 90, 180, 365, 1095, 1825];
const _cycleLabels = ['每月', '每 3 月', '每 6 月', '每年', '每 3 年', '每 5 年'];

/// Document 用 4 档（30/60/90 天）。
const _leadDocOptions = <int>[0, 30, 60, 90];
const _leadDocLabels = ['当天', '30 天', '60 天', '90 天'];

// ── 家居维护 sheet ───────────────────────────────────────────────────────

class HomeSheet extends ConsumerStatefulWidget {
  const HomeSheet({super.key});

  @override
  ConsumerState<HomeSheet> createState() => _HomeSheetState();
}

class _HomeSheetState extends ConsumerState<HomeSheet> {
  final _nameController = TextEditingController();
  int _cycleDays = 180;
  int _leadDays = 7;
  String? _error;

  // 12 项按语义分组 —— 4 段（个人护理 2 / 滤芯滤网 6 / 寝具 2 / 安全 2）。
  // 分组让 4×3 平铺不显单调，给 grid 提供节奏。
  // AppIcons.xxx() 返回 outline widget 非 const，故用 final。
  static final _sections = <(String, List<(String, Widget)>)>[
    (
      '个人护理',
      [
        ('牙刷', AppIcons.brush()),
        ('电动牙刷头', AppIcons.brush()),
      ],
    ),
    (
      '滤芯 / 滤网',
      [
        ('空气净化器滤芯', AppIcons.wind()),
        ('净水器滤芯', AppIcons.water()),
        ('空调滤芯', AppIcons.airConditioning()),
        ('油烟机滤网', AppIcons.cook()),
        ('洗衣机滤网', AppIcons.washingMachine()),
        ('淋浴头', AppIcons.shower()),
      ],
    ),
    (
      '寝具',
      [
        ('枕头', AppIcons.sleep()),
        ('床垫', AppIcons.bed()),
      ],
    ),
    (
      '安全',
      [
        ('烟雾报警器电池', AppIcons.fire()),
        ('灭火器', AppIcons.fireExtinguisher()),
      ],
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty;
    return SheetScaffold(
      title: '添加家居',
      actionDisabled: !canSubmit,
      onAction: _submit,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetField(
            label: '名称',
            value: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '如：净水器滤芯 / 牙刷',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '常用项',
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _sections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _SectionLabel(text: _sections[i].$1),
                  const SizedBox(height: 10),
                  PresetIconGrid(
                    items: _sections[i].$2,
                    selected: _nameController.text.trim(),
                    onChanged: _pickPreset,
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '周期',
            value: SegmentedControl<int>(
              options: _cycleOptions,
              selected: _cycleDays,
              onChanged: (v) => setState(() => _cycleDays = v),
              labels: _cycleLabels,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '提前提醒',
            value: RemindBeforeSegmented(
              value: _leadDays,
              onChanged: (v) => setState(() => _leadDays = v),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SheetErrorBox(message: _error!),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _pickPreset(String label) {
    _nameController.text = label;
    _nameController.selection = TextSelection.collapsed(offset: label.length);
    setState(() {});
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请填一个名称');
      return;
    }
    unawaited(_addSub(
      ref,
      Subscription(
        id: 0,
        title: name,
        type: SubType.homeMaintenance,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: _cycleDays,
        leadDays: _leadDays,
        active: true,
        createdAt: DateTime.now(),
      ),
    ));
    Navigator.pop(context);
  }
}

// ── 宠物 sheet ───────────────────────────────────────────────────────────

class PetSheet extends ConsumerStatefulWidget {
  const PetSheet({super.key});

  @override
  ConsumerState<PetSheet> createState() => _PetSheetState();
}

class _PetSheetState extends ConsumerState<PetSheet> {
  // 6 项种类 —— 平铺 1 行即可，无需分组
  static final _species = <(String, Widget)>[
    ('狗狗', AppIcons.pet()),
    ('猫咪', AppIcons.cat()),
    ('兔子', AppIcons.rabbit()),
    ('仓鼠', AppIcons.bear()),
    ('鸟类', AppIcons.bird()),
    ('其他', AppIcons.more()),
  ];

  // 10 项事项 —— 平铺 4 行（3+3+3+1），不分组避免单组 < 3 显得稀疏
  static final _careTypes = <(String, Widget)>[
    ('狂犬疫苗', AppIcons.injection()),
    ('核心疫苗', AppIcons.injection()),
    ('心丝虫', AppIcons.heart()),
    ('跳蚤蜱虫', AppIcons.bug()),
    ('体内驱虫', AppIcons.protect()),
    ('体外驱虫', AppIcons.protect()),
    ('体检', AppIcons.stethoscope()),
    ('牙科', AppIcons.teeth()),
    ('洗澡', AppIcons.shower()),
    ('剪指甲', AppIcons.scissors()),
  ];

  final _nameController = TextEditingController();
  String? _selectedSpecies;
  String? _selectedCareType;
  int _cycleDays = 365;
  int _leadDays = 7;
  DateTime? _lastDate;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _nameController.text.trim().isNotEmpty &&
        _selectedCareType != null &&
        _lastDate != null;
    return SheetScaffold(
      title: '添加宠物',
      actionDisabled: !canSubmit,
      onAction: _submit,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetField(
            label: '宠物名',
            value: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: '如：豆豆',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '种类',
            value: PresetIconGrid(
              items: _species,
              selected: _selectedSpecies,
              onChanged: (v) => setState(() => _selectedSpecies = v),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '事项',
            value: PresetIconGrid(
              items: _careTypes,
              selected: _selectedCareType,
              onChanged: (v) => setState(() => _selectedCareType = v),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '周期',
            value: SegmentedControl<int>(
              options: _cycleOptions,
              selected: _cycleDays,
              onChanged: (v) => setState(() => _cycleDays = v),
              labels: _cycleLabels,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '上次日期',
            valueMuted: _lastDate == null,
            value: SheetDateField(
              date: _lastDate,
              placeholder: '选择日期',
              onTap: _pickDate,
              onClear: () => setState(() => _lastDate = null),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '提前提醒',
            value: RemindBeforeSegmented(
              value: _leadDays,
              onChanged: (v) => setState(() => _leadDays = v),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SheetErrorBox(message: _error!),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await pickSheetDate(
      context,
      initial: _lastDate ?? DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _lastDate = picked);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = '请填宠物名');
      return;
    }
    if (_selectedCareType == null) {
      setState(() => _error = '请选一个事项');
      return;
    }
    if (_lastDate == null) {
      setState(() => _error = '请选上次日期');
      return;
    }
    final species = _selectedSpecies ?? '';
    final title = species.isEmpty
        ? '$_selectedCareType（$name）'
        : '$_selectedCareType（$name·$species）';
    unawaited(_addSub(
      ref,
      Subscription(
        id: 0,
        title: title,
        type: SubType.petCare,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: _cycleDays,
        leadDays: _leadDays,
        createdAt: _lastDate!,
      ),
    ));
    Navigator.pop(context);
  }
}

// ── 证件 sheet ───────────────────────────────────────────────────────────

class DocumentSheet extends ConsumerStatefulWidget {
  const DocumentSheet({super.key});

  @override
  ConsumerState<DocumentSheet> createState() => _DocumentSheetState();
}

class _DocumentSheetState extends ConsumerState<DocumentSheet> {
  // 10 项证件类型 —— 平铺 4 行（3+3+3+1），无明显子分组（不像车辆有 保养/美容/保险）
  static final _docTypes = <(String, Widget)>[
    ('身份证', AppIcons.idCardH()),
    ('护照', AppIcons.passport()),
    ('驾驶证', AppIcons.certificate()),
    ('行驶证', AppIcons.idCardV()),
    ('港澳通行证', AppIcons.passportOne()),
    ('居住证', AppIcons.idCard()),
    ('社保卡', AppIcons.bankCard()),
    ('医保卡', AppIcons.medicalFiles()),
    ('信用卡', AppIcons.bill()),
    ('会员卡', AppIcons.vip()),
  ];

  final _holderController = TextEditingController();
  String? _selectedDocType;
  DateTime? _expiryDate;
  int _leadDays = 30;
  String? _error;

  @override
  void dispose() {
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _selectedDocType != null &&
        _holderController.text.trim().isNotEmpty &&
        _expiryDate != null;
    return SheetScaffold(
      title: '添加证件',
      actionDisabled: !canSubmit,
      onAction: _submit,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetField(
            label: '证件类型',
            value: PresetIconGrid(
              items: _docTypes,
              selected: _selectedDocType,
              onChanged: (v) => setState(() => _selectedDocType = v),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '持有人',
            value: TextField(
              controller: _holderController,
              decoration: const InputDecoration(
                hintText: '如：我 / 爸爸 / 妈妈',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '到期日',
            valueMuted: _expiryDate == null,
            value: SheetDateField(
              date: _expiryDate,
              placeholder: '选择到期日',
              onTap: _pickDate,
              onClear: () => setState(() => _expiryDate = null),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '提前提醒',
            value: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < _leadDocOptions.length; i++)
                  PresetChip(
                    label: _leadDocLabels[i],
                    isSelected: _leadDocOptions[i] == _leadDays,
                    onTap: () => setState(() => _leadDays = _leadDocOptions[i]),
                  ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SheetErrorBox(message: _error!),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await pickSheetDate(
      context,
      initial: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() => _expiryDate = picked);
    }
  }

  void _submit() {
    if (_selectedDocType == null) {
      setState(() => _error = '请选证件类型');
      return;
    }
    final holder = _holderController.text.trim();
    if (holder.isEmpty) {
      setState(() => _error = '请填持有人');
      return;
    }
    if (_expiryDate == null) {
      setState(() => _error = '请选到期日');
      return;
    }
    unawaited(_addSub(
      ref,
      Subscription(
        id: 0,
        title: '${holder}的$_selectedDocType',
        type: SubType.document,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: _expiryDate!.month,
        anchorDay: _expiryDate!.day,
        leadDays: _leadDays,
        createdAt: DateTime.now(),
      ),
    ));
    Navigator.pop(context);
  }
}

// ── 健康 sheet ───────────────────────────────────────────────────────────

class HealthSheet extends ConsumerStatefulWidget {
  const HealthSheet({super.key});

  @override
  ConsumerState<HealthSheet> createState() => _HealthSheetState();
}

class _HealthSheetState extends ConsumerState<HealthSheet> {
  // 8 项顶层类型 —— 平铺 3 行（3+3+2），无明显子分组
  static final _projectTypes = <(String, Widget)>[
    ('全身体检', AppIcons.stethoscope()),
    ('牙科', AppIcons.teeth()),
    ('眼科', AppIcons.eyes()),
    ('皮肤', AppIcons.handCream()),
    ('妇科男科', AppIcons.peoples()),
    ('疫苗', AppIcons.injection()),
    ('影像筛查', AppIcons.scan()),
    ('慢病复查', AppIcons.heartRate()),
  ];

  // 15 项常用项 —— 4 段（检查 4 / 筛查 5 / 监测 2 / 疫苗 4）。
  // 妇科检查归入 筛查（与乳腺/宫颈同类：专科门诊）。
  static final _healthCheckSections = <(String, List<(String, Widget)>)>[
    (
      '检查',
      [
        ('全身体检', AppIcons.stethoscope()),
        ('牙科检查', AppIcons.teeth()),
        ('眼科检查', AppIcons.eyes()),
        ('皮肤检查', AppIcons.handCream()),
      ],
    ),
    (
      '筛查',
      [
        ('乳腺筛查', AppIcons.medicalBox()),
        ('宫颈筛查', AppIcons.medicalBox()),
        ('前列腺检查', AppIcons.medicalBox()),
        ('骨密度', AppIcons.medicalBox()),
        ('妇科检查', AppIcons.peoples()),
      ],
    ),
    (
      '监测',
      [
        ('血压监测', AppIcons.heartRate()),
        ('血糖/血脂', AppIcons.electrocardiogram()),
      ],
    ),
    (
      '疫苗',
      [
        ('流感疫苗', AppIcons.injection()),
        ('HPV疫苗', AppIcons.injection()),
        ('肺炎疫苗', AppIcons.injection()),
        ('带状疱疹疫苗', AppIcons.injection()),
      ],
    ),
  ];

  final _whoController = TextEditingController();
  String? _selectedProject;
  String? _selectedPreset;
  int _cycleDays = 365;
  int _leadDays = 30;
  DateTime? _lastDate;
  String? _error;

  @override
  void dispose() {
    _whoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _whoController.text.trim().isNotEmpty &&
        _selectedProject != null &&
        _lastDate != null;
    return SheetScaffold(
      title: '添加健康',
      actionDisabled: !canSubmit,
      onAction: _submit,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetField(
            label: '类型',
            value: PresetIconGrid(
              items: _projectTypes,
              selected: _selectedProject,
              onChanged: (v) => setState(() => _selectedProject = v),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '常用项',
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _healthCheckSections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _SectionLabel(text: _healthCheckSections[i].$1),
                  const SizedBox(height: 10),
                  PresetIconGrid(
                    items: _healthCheckSections[i].$2,
                    selected: _selectedPreset,
                    onChanged: (v) => setState(() => _selectedPreset = v),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '谁',
            value: TextField(
              controller: _whoController,
              decoration: const InputDecoration(
                hintText: '如：我 / 爸爸 / 妈妈',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '上次日期',
            valueMuted: _lastDate == null,
            value: SheetDateField(
              date: _lastDate,
              placeholder: '选择日期',
              onTap: _pickDate,
              onClear: () => setState(() => _lastDate = null),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '周期',
            value: SegmentedControl<int>(
              options: _cycleOptions,
              selected: _cycleDays,
              onChanged: (v) => setState(() => _cycleDays = v),
              labels: _cycleLabels,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '提前提醒',
            value: RemindBeforeSegmented(
              value: _leadDays,
              onChanged: (v) => setState(() => _leadDays = v),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SheetErrorBox(message: _error!),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await pickSheetDate(
      context,
      initial: _lastDate ?? DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _lastDate = picked);
    }
  }

  void _submit() {
    final who = _whoController.text.trim();
    if (who.isEmpty) {
      setState(() => _error = '请填是谁');
      return;
    }
    if (_selectedProject == null) {
      setState(() => _error = '请选类型');
      return;
    }
    if (_lastDate == null) {
      setState(() => _error = '请选上次日期');
      return;
    }
    final title = _selectedPreset != null
        ? '$_selectedPreset（$who）'
        : '$_selectedProject（$who）';
    unawaited(_addSub(
      ref,
      Subscription(
        id: 0,
        title: title,
        type: SubType.healthCheck,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: _cycleDays,
        leadDays: _leadDays,
        createdAt: _lastDate!,
      ),
    ));
    Navigator.pop(context);
  }
}

// ── 车辆 sheet ───────────────────────────────────────────────────────────

class VehicleSheet extends ConsumerStatefulWidget {
  const VehicleSheet({super.key});

  @override
  ConsumerState<VehicleSheet> createState() => _VehicleSheetState();
}

class _VehicleSheetState extends ConsumerState<VehicleSheet> {
  // 8 项顶层事项 —— 平铺 3 行（3+3+2）
  static final _serviceTypes = <(String, Widget)>[
    ('机油更换', AppIcons.petrol()),
    ('滤芯', AppIcons.filter()),
    ('刹车', AppIcons.brakePads()),
    ('轮胎', AppIcons.recordDisc()),
    ('液体', AppIcons.water()),
    ('证件', AppIcons.certificate()),
    ('电瓶', AppIcons.carBattery()),
    ('外观', AppIcons.paint()),
  ];

  // 18 项常用项 —— 5 段（保养件 6 / 刹车与油液 4 / 轮胎 2 / 美容 3 / 证件与保险 3）。
  // 「保养件」合 6 项放一组节省高度，避免每组只 2-3 项碎片化。
  static final _vehicleSections = <(String, List<(String, Widget)>)>[
    (
      '保养件',
      [
        ('矿物质机油', AppIcons.petrol()),
        ('全合成机油', AppIcons.petrol()),
        ('空气滤芯', AppIcons.wind()),
        ('空调滤芯', AppIcons.airConditioning()),
        ('火花塞', AppIcons.electricWave()),
        ('雨刮片', AppIcons.water()),
      ],
    ),
    (
      '刹车 / 油液',
      [
        ('刹车片', AppIcons.brakePads()),
        ('刹车油', AppIcons.petrol()),
        ('变速箱油', AppIcons.petrol()),
        ('冷却液', AppIcons.water()),
      ],
    ),
    (
      '轮胎',
      [
        ('轮胎换位', AppIcons.recordDisc()),
        ('轮胎更换', AppIcons.recordDisc()),
      ],
    ),
    (
      '美容',
      [
        ('车身打蜡', AppIcons.paint()),
        ('内饰清洁', AppIcons.vacuumCleaner()),
        ('空调消毒', AppIcons.wind()),
      ],
    ),
    (
      '证件 / 保险',
      [
        ('年检', AppIcons.certificate()),
        ('交强险', AppIcons.shield()),
        ('商业险', AppIcons.shield()),
      ],
    ),
  ];

  static const _condOptions = ['按时间', '按里程'];

  final _vehicleController = TextEditingController();
  final _mileageController = TextEditingController();
  String? _selectedService;
  String? _selectedPreset;
  int _condIndex = 0; // 0=按时间, 1=按里程
  int _cycleDays = 365;
  int _leadDays = 14;
  DateTime? _lastDate;
  String? _error;

  @override
  void dispose() {
    _vehicleController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final byTime = _condIndex == 0;
    final canSubmit = _vehicleController.text.trim().isNotEmpty &&
        _selectedService != null &&
        (byTime ? _lastDate != null : _mileageController.text.trim().isNotEmpty);
    return SheetScaffold(
      title: '添加车辆',
      actionDisabled: !canSubmit,
      onAction: _submit,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetField(
            label: '车辆',
            value: TextField(
              controller: _vehicleController,
              decoration: const InputDecoration(
                hintText: '如：我的车 / 家里 SUV',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '事项',
            value: PresetIconGrid(
              items: _serviceTypes,
              selected: _selectedService,
              onChanged: (v) => setState(() => _selectedService = v),
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '常用项',
            value: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < _vehicleSections.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  _SectionLabel(text: _vehicleSections[i].$1),
                  const SizedBox(height: 10),
                  PresetIconGrid(
                    items: _vehicleSections[i].$2,
                    selected: _selectedPreset,
                    onChanged: (v) => setState(() => _selectedPreset = v),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '提醒条件',
            value: SegmentedControl<int>(
              options: const [0, 1],
              selected: _condIndex,
              onChanged: (v) => setState(() => _condIndex = v),
              labels: _condOptions,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderSoft),
          if (byTime) ...[
          SheetField(
            label: '上次日期',
            valueMuted: _lastDate == null,
            value: SheetDateField(
              date: _lastDate,
              placeholder: '选择日期',
              onTap: _pickDate,
              onClear: () => setState(() => _lastDate = null),
            ),
          ),
            const Divider(height: 28, color: AppColors.borderSoft),
            SheetField(
              label: '周期',
              value: SegmentedControl<int>(
                options: _cycleOptions,
                selected: _cycleDays,
                onChanged: (v) => setState(() => _cycleDays = v),
                labels: _cycleLabels,
              ),
            ),
          ] else ...[
            SheetField(
              label: '上次里程（km）',
              value: TextField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '如：50000',
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
          const Divider(height: 28, color: AppColors.borderSoft),
          SheetField(
            label: '提前提醒',
            value: RemindBeforeSegmented(
              value: _leadDays,
              onChanged: (v) => setState(() => _leadDays = v),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SheetErrorBox(message: _error!),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await pickSheetDate(
      context,
      initial: _lastDate ?? DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _lastDate = picked);
    }
  }

  void _submit() {
    final vehicle = _vehicleController.text.trim();
    if (vehicle.isEmpty) {
      setState(() => _error = '请填车辆');
      return;
    }
    if (_selectedService == null) {
      setState(() => _error = '请选事项');
      return;
    }
    final byTime = _condIndex == 0;
    DateTime createdAt;
    int intervalDays;
    if (byTime) {
      if (_lastDate == null) {
        setState(() => _error = '请选上次日期');
        return;
      }
      createdAt = _lastDate!;
      intervalDays = _cycleDays;
    } else {
      // ponytail: 里程数据无原生字段，借 intervalDays 占位。模型扩展后再拆。
      final mileage = int.tryParse(_mileageController.text.trim()) ?? 0;
      if (mileage <= 0) {
        setState(() => _error = '请填上次里程');
        return;
      }
      createdAt = DateTime.now();
      intervalDays = mileage;
    }
    final body = _selectedPreset ?? _selectedService!;
    final title = '$body（$vehicle）';
    unawaited(_addSub(
      ref,
      Subscription(
        id: 0,
        title: title,
        type: SubType.vehicle,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: intervalDays,
        leadDays: _leadDays,
        createdAt: createdAt,
      ),
    ));
    Navigator.pop(context);
  }
}

/// 小节标题 —— uppercase + muted + letter-spacing，模仿 docs 里的
/// `.detail-section`。仅 HomeSheet 在 preset grid 上方使用。
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.muted,
        letterSpacing: 0.6,
      ),
    );
  }
}
