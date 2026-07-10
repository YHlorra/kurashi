<a id="readme-top"></a>

**[English](README.md) | [中文](README.zh-CN.md)**

<br />
<div align="center">
  <h3 align="center">kurashi (暮らし)</h3>
  <p align="center">
    今日待办 + 周期提醒 + 冰箱管理 —— 农历感知、纯本地、Android + iOS。
    <br />
    为个人生活打造。无账号、无广告、无云端。
    <br />
    <br />
    <a href="#getting-started">开始使用</a>
    ·
    <a href="#usage">使用方法</a>
    ·
    <a href="https://github.com/kurashi-app/kurashi/issues">反馈问题</a>
  </p>
</div>

<details>
<summary>目录</summary>
<ol>
<li><a href="#关于本项目">关于本项目</a></li>
<li><a href="#技术栈">技术栈</a></li>
<li><a href="#开始使用">开始使用</a>
<ul>
<li><a href="#环境要求">环境要求</a></li>
<li><a href="#安装">安装</a></li>
</ul>
</li>
<li><a href="#使用方法">使用方法</a>
<ul>
<li><a href="#今日待办">今日待办</a></li>
<li><a href="#周期提醒">周期提醒</a></li>
<li><a href="#冰箱管理">冰箱管理</a></li>
</ul>
</li>
<li><a href="#测试">测试</a></li>
<li><a href="#部署">部署</a></li>
<li><a href="#路线图">路线图</a></li>
<li><a href="#贡献">贡献</a></li>
<li><a href="#许可证">许可证</a></li>
<li><a href="#致谢">致谢</a></li>
</ol>
</details>

## 关于本项目

**kurashi**（暮らし —— 日语「生活」）是一款 **Android + iOS** 个人生活管理应用。三个标签页、一个本地数据库、零云端。

| 标签页 | 功能 |
|--------|------|
| **今日** | 待办事项、习惯打卡、订阅提醒，按时间混排一屏展示 |
| **订阅** | 节日 / 生日 / 还款 / 自定义周期提醒，原生支持农历 |
| **冰箱** | 食材入库、过期预警、智能补货建议、完整变更记录（JSON 导出） |

为**个人日常使用**而设计和开发。开发者做这个 app 是为了解决自己的生活痛点：农历节日需要手动算、现有 app 没有纯本地的订阅提醒、冰箱里的东西经常被遗忘直到过期。全部数据本地存储：无账号、无追踪、无广告、无协作。你的数据只在你自己的设备上。

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

### 技术栈

* [![Flutter][Flutter-shield]][Flutter-url]
* [![Dart][Dart-shield]][Dart-url]
* [![Riverpod][Riverpod-shield]][Riverpod-url]
* [![Isar][Isar-shield]][Isar-url]
* [![Lunar][Lunar-shield]][Lunar-url]

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 开始使用

### 环境要求

* Flutter 3.41.x（stable 渠道）— [安装指南](https://docs.flutter.dev/get-started/install)
* Dart 3.12+
* Android Studio / Xcode（对应平台构建）
* 真机或模拟器

### 安装

1. 克隆仓库
   ```sh
   git clone https://github.com/kurashi-app/kurashi.git
   cd kurashi
   ```
2. 安装依赖
   ```sh
   flutter pub get
   ```
3. 运行代码生成（Isar 集合和 Riverpod 必需）
   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```
4. 在设备或模拟器上运行
   ```sh
   flutter run -d <device-id>
   ```

列出可用设备：
```sh
flutter devices
```

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 使用方法

### 今日

默认页面。三种数据源按时间混排：

* **待办事项** —— 可选截止日期和具体时间
* **习惯打卡** —— 周频次目标（比如「阅读 30 分钟，每周 3 次」）
* **订阅锚点** —— 来自订阅标签页的近期提醒，在相关时出现在今日视图

已完成的待办在「今日」视图中立即消失。

### 订阅

为任何重复事件创建提醒：

| 类型 | 示例 | 历法 |
|------|------|------|
| 中国节日 | 春节、中秋、清明 | 农历 |
| 西方节日 | 母亲节、感恩节 | 公历 |
| 生日 | 「爸爸生日，农历七月初八，提前 3 天提醒」 | 农历或公历 |
| 还款 | 「信用卡还款，每月 5 号」 | 公历 |
| 自定义 |「净水器滤芯，每 180 天更换」 | 智能间隔 |
| 家居 | 「烟雾报警器电池，每年更换」 | 公历 |
| 宠物 | 「心丝虫预防，每 30 天」 | 公历 |
| 证件 | 「驾照到期换证，提前 90 天」 | 公历 |
| 健康 | 「年度体检」「每 6 个月洗牙」 | 公历 |
| 车辆 | 「机油更换，每年」「续交强险」 | 公历 |

活跃提醒按距今天数升序排列，并在「今日」页面中展示。

### 冰箱

管理食材库存，减少浪费：

* **添加食材** —— 名称、数量、过期日期、标签（蔬菜 / 水果 / 肉类 / 自定义）
* **过期预警** —— 临近过期的食材自动出现在补货清单
* **智能补货** —— 开启补货提醒的食材在库存低于阈值时自动建议补货（每个食材独立设置）
* **变更记录** —— 每次添加 / 编辑 / 删除 / 撤销都记录前后值。支持 JSON 导出，方便分析
* **保留策略** —— 可设置日志保留 30 天、90 天、或永久

#### 构建 Release APK

```sh
flutter build apk --release
# 输出路径：build/app/outputs/flutter-apk/app-release.apk
```

安装到设备：
```sh
adb install build/app/outputs/flutter-apk/app-release.apk
```

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 测试

```sh
# 运行全部测试
flutter test

# 带覆盖率
flutter test --coverage

# 静态分析
flutter analyze
```

89 个单元测试 + 部件测试，覆盖仓库行为、农历计算、通知调度、部件渲染。

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 部署

本项目使用 [GitHub Actions](.github/workflows/build.yml) 作为 CI：

* 每次 push 和 PR 自动运行 **静态分析** + **测试套件**
* 测试通过后自动构建 **Release APK**（作为运行产物附件）

Workflow 使用 Flutter 4.41.4，运行于 `ubuntu-latest` + Java 17。

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 路线图

- [x] 今日页面：待办 + 习惯 + 订阅锚点
- [x] 周期提醒（农历 + 公历）
- [x] 冰箱库存 + 过期预警
- [x] 变更记录 + JSON 导出
- [x] 补货建议
- [x] 保留策略
- [ ] JSON 导入（从导出恢复）
- [ ] 按批次追踪（比如 3 个鸡蛋一个个用）
- [ ] 多主题（当前仅黑白）
- [ ] 桌面小部件 / 快捷添加

路线图反映开发者的个人需求。新功能按日常痛点优先级决定，而非投票数。

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 贡献

这是一个**个人项目**——开发者做它是为了解决自己的日常生活问题。欢迎提交 issue 和建议，但功能优先级由个人需求决定。

如果你遇到问题：

1. 先确认是不是个人偏好差异（这个 app 本身就是按开发者个人习惯设计的）
2. 查看已有的 issue
3. 新建 issue，说明：你期望的行为、实际发生的行为、复现步骤

方向与 app 一致（本地优先、极简、个人规模）的 PR 可以接纳。大型架构变更或社交/云端功能基本不在考虑范围内。

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 许可证

基于 MIT 许可证分发。详见 `LICENSE`。

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

## 致谢

* [lunar](https://github.com/6tail/lunar-flutter) —— 农历计算
* [IconPark](https://iconpark.oceanengine.com/) —— 线性图标库
* [Inter](https://rsms.me/inter/) / [JetBrains Mono](https://www.jetbrains.com/lp/mono/) / [Noto Sans SC](https://fonts.google.com/noto) —— 内嵌字体

<p align="right">(<a href="#readme-top">回到顶部</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- Shields -->
[Flutter-shield]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev
[Dart-shield]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev
[Riverpod-shield]: https://img.shields.io/badge/Riverpod-0F52BA?style=for-the-badge&logo=flutter&logoColor=white
[Riverpod-url]: https://riverpod.dev
[Isar-shield]: https://img.shields.io/badge/Isar-3DDC84?style=for-the-badge&logo=dart&logoColor=white
[Isar-url]: https://isar.dev
[Lunar-shield]: https://img.shields.io/badge/Lunar_Calendar-8B0000?style=for-the-badge&logoColor=white
[Lunar-url]: https://github.com/6tail/lunar-flutter
[license-shield]: https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge
[license-url]: ./LICENSE
<!-- TODO: Replace OWNER/REPO after setting up GitHub remote -->
<!-- [version-shield]: https://img.shields.io/github/v/tag/OWNER/REPO?style=for-the-badge -->
<!-- [version-url]: https://github.com/OWNER/REPO/releases -->
<!-- [last-commit-shield]: https://img.shields.io/github/last-commit/OWNER/REPO?style=for-the-badge -->
<!-- [last-commit-url]: https://github.com/OWNER/REPO/commits/main -->
<!-- [ci-shield]: https://img.shields.io/github/actions/workflow/status/OWNER/REPO/build.yml?style=for-the-badge -->
<!-- [ci-url]: https://github.com/OWNER/REPO/actions -->
