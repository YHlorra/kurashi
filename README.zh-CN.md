**[中文](README.zh-CN.md) | [English](README.en.md)**

<h1 align="center">kurashi</h1>

<p align="center">
  暮らし — Todo + 周期提醒 + 冰箱<br>
  农历原生 · 本地优先 · Android + iOS
</p>

<p align="center">
  <a href="https://github.com/YHlorra/kurashi/actions"><img src="https://img.shields.io/github/actions/workflow/status/YHlorra/kurashi/build.yml?logo=github&label=Build" alt="Build"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-MIT-black" alt="MIT License"></a>
</p>



- [这是什么](#what-it-is)
- [为什么造这个](#why-i-built-this)
- [怎么用](#quick-start)
- [核心能力](#features)
- [已知边界](#known-limits)
- [测试](#testing)
- [路线图](#roadmap)
- [关于作者](#about-the-author)
- [License](#license)

## 这是什么

**kurashi**（日语「暮らし」，意为「生活」）是一个 Android + iOS 双平台的生活管理 App。三个标签页，一个本地数据库，零云同步。

| 标签页 | 做什么 |
|--------|--------|
| **Today** | 把今日待办、习惯打卡、即将到来的提醒合并成一条时间线 |
| **Subscription** | 为节日、生日、账单、自定义事项创建循环提醒 —— 农历/公历双轨原生 |
| **Fridge** | 食材库存管理、临期预警、智能补货建议，完整操作日志可 JSON 导出 |

> [!NOTE]
> 全部数据存于本机。无账号、无广告、无追踪、无协作。你的数据只属于你。

## 为什么造这个

现有日历 App 要么堆满了节气黄历星座广告，要么不带农历。万年历 App 不支持按「提醒我妈妈农历生日提前三天」这种方式管理循环事项。冰箱里的东西经常放到过期才发现。

kurashi 是为解决这三个日常摩擦而造的 —— 一个干净的、按自己节奏来的生活工具。功能优先级由每日真实的痛点决定，不是热度。

## 怎么用

### 环境要求

- Flutter 3.41.x（stable）— [安装指南](https://docs.flutter.dev/get-started/install)
- Dart 3.12+
- Android Studio 或 Xcode（构建平台产物）
- 真机或模拟器

### 本地运行

```sh
git clone https://github.com/YHlorra/kurashi.git
cd kurashi
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d <device-id>
```

> [!NOTE]
> `build_runner` 是必须的 —— Isar 数据库和 Riverpod 代码生成都依赖它。首次运行后，后续修改可用 `dart run build_runner watch` 自动增量生成。

列出可用设备：

```sh
flutter devices
```

### 构建发布包

```sh
# Release APK
flutter build apk --release
# 产物路径: build/app/outputs/flutter-apk/app-release.apk

# iOS（无需签名，模拟器用）
flutter build ios --debug --no-codesign
```

## 核心能力

### Today（今日）

把三种数据源合并成一个按时间排序的滚动列表：

- **Todos** — 可选具体日期和时间（精确到 HH:mm）
- **Habits** — 每周频率目标（如「阅读 30 分钟 × 3/周」），支持打卡
- **Subscription anchors** — 将近的提醒浮升到今日视图

完成的事项立即从今日视图消失。

### Subscription（周期提醒）

为任何重复事项创建提醒：

| 类型 | 示例 | 日历 |
|------|------|------|
| 中国节日 | 春节、中秋、清明 | 农历 |
| 西方节日 | 母亲节、感恩节 | 公历 |
| 生日 | 「爸爸生日，农历七月初八，提前 3 天提醒」 | 农历或公历 |
| 账单 | 「信用卡还款，每月 5 号」 | 公历 |
| 自定义 | «净水器滤芯更换，每 180 天» | 智能间隔 |

另外内置 Home / Pets / Documents / Health / Vehicle 等分类模板。活跃提醒按「距下次天数」排序并在 Today 标签浮升。

### Fridge（冰箱）

食材库存管理，减少浪费：

- **添加食材** — 名称、数量、过期日期、标签（蔬菜/肉类/水果/自定义）
- **临期追踪** — 临近过期的食材自动浮升到补货列表
- **智能补货** — 补货开启后按自定义库存阈值自动生成购物清单
- **操作日志** — 每次添加/编辑/删除/撤销都有前后值记录，可 JSON 导出
- **保留策略** — 日志保留 30 天、90 天或永久

### 技术架构

Feature-first 目录结构，UI 与数据库之间用抽象 Repository 接口解耦：

```
lib/
├── app.dart                      # MaterialApp 根组件
├── main.dart                     # 入口：预热 Isar + 初始化通知
├── core/                         # 基础设施（无 feature 依赖）
│   ├── database/                 # Isar provider + schema
│   ├── designsystem/             # 主题、图标、通用组件
│   ├── lunar/                    # 农历服务 + 节日预设
│   ├── navigation/               # go_router 路由
│   └── notifications/            # 通知调度 + workmanager
├── data/
│   ├── models/                   # Isar 实体
│   └── repositories/             # 抽象接口 + Fake/Isar 双实现
└── feature/
    ├── todo/                     # Today 标签
    ├── subscription/             # Subscription 标签
    └── fridge/                   # Fridge 标签
```

Repository 抽象让切换 Fake（内存 mock）→ Isar（真持久化）只是一行 provider 的差异 —— UI 层零改动。

## 已知边界

- ✅ Android + iOS 真机运行
- ✅ 农历 / 公历双轨
- ✅ 本地通知 + workmanager 后台保活
- ✅ JSON 导出
- ❌ 无 Web / 桌面端（Isar_plus 仅支持 Android/iOS）
- ❌ 无云同步 / 多设备
- ❌ 无 JSON 导入（导出已有，导入尚未实现）
- ❌ 无多批次过期（如「3 个鸡蛋逐个使用」）
- ❌ 无桌面小组件 / 快捷添加

## 测试

14 个测试文件，覆盖仓库行为、农历计算、通知调度、Widget 渲染。

```sh
# 运行全套测试
flutter test

# 覆盖率
flutter test --coverage

# 静态分析
flutter analyze
```

CI 由 GitHub Actions 驱动：

- 每次 push / PR 触发 analyze + format check + test
- 测试通过后自动构建 Release APK（artifact 保留 30 天）
- PR 额外构建 Debug APK 用于快速验证

## 路线图

- [x] Today 标签（待办 + 习惯 + 提醒锚点）
- [x] 农历 + 公历双轨提醒
- [x] 冰箱库存 + 临期追踪
- [x] 操作日志 + JSON 导出
- [x] 智能补货建议
- [x] 日志保留策略
- [ ] JSON 导入（从导出恢复）
- [ ] 单食材多批次过期
- [ ] 主题扩展（当前为黑白极简）
- [ ] 桌面小组件 / 快捷添加

路线图反映开发者个人需求，按真实摩擦优先级推进。

## 关于作者

kurashi 是一个个人项目，由开发者为日常需求而造。

<!-- TODO: 填入你的名字 / 社交链接 -->

## License

MIT © kurashi. 详见 [LICENSE](./LICENSE)。


