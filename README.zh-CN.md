# tw_iphone_duo_reserved_region

[English](README.md) | 简体中文

一个 Flutter 插件，用于将当前处于激活状态的 iPhone Duo Reserved Region
转换为 Flutter 窗口逻辑坐标中的矩形。应用可以根据这些几何信息避开系统拥有的遮挡区域，
同时继续自主决定控件移动、隐藏或切换布局的方式。

插件只负责查询、校验和分发几何信息，不会自动修改业务界面。

## 平台支持

| 平台 | 行为 |
| --- | --- |
| iOS 27.1 及以上 | 查询当前激活的遮挡 Reserved Region。 |
| 较早的 iOS 版本 | 返回 `null`，应用继续使用普通回退布局。 |
| 其他 Flutter 平台 | 不调用平台通道，直接返回 `null`。 |

插件的最低部署版本为 iOS 15.5。Reserved Region API 使用运行时可用性检查，因此同一份
应用二进制仍可运行在插件支持的较早 iOS 版本上。

## 环境要求

- Dart `>=3.10.0 <4.0.0`
- Flutter 3.44 或更高版本
- iOS Deployment Target 15.5 或更高版本
- Xcode 27.1 或更高版本，并包含 iOS 27.1 SDK

即使应用需要兼容较早的 iOS 运行时，编译阶段仍必须使用包含 Reserved Region API 声明的
iOS 27.1 SDK。

## 安装

从 pub.dev 添加已发布的 `1.0.0` 版本：

```yaml
dependencies:
  tw_iphone_duo_reserved_region: ^1.0.0
```

也可以使用命令行：

```console
flutter pub add tw_iphone_duo_reserved_region
```

本地开发时可以改用路径依赖：

```yaml
dependencies:
  tw_iphone_duo_reserved_region:
    path: ../tw_iphone_duo_reserved_region
```

然后解析依赖：

```console
flutter pub get
```

## 原生依赖管理

iOS 实现同时支持 Swift Package Manager 和 CocoaPods：

- Flutter 3.44 及以上版本默认使用 Swift Package Manager。
- 仍使用 CocoaPods 的项目可以通过插件自带的 podspec 集成相同的原生实现。
- 两种依赖管理方式共用一套 Objective-C 源码，不存在两份实现分叉的问题。

通常不需要在业务工程中手动选择包管理器，Flutter 会根据工程配置完成集成。

## 基本用法

将 `TwIphoneDuoReservedRegionBridge` 放在需要读取 Reserved Region 的组件树上方。
放在应用根部可以让返回的矩形与顶层窗口布局使用相同的坐标空间。

```dart
import 'package:flutter/material.dart';
import 'package:tw_iphone_duo_reserved_region/tw_iphone_duo_reserved_region.dart';

void main() {
  runApp(
    const TwIphoneDuoReservedRegionBridge(
      child: MaterialApp(home: HomePage()),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Rect>? regions =
        TwIphoneDuoReservedRegionProvider.activeOcclusionRegionsOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_statusFor(regions)),
        ),
      ),
    );
  }

  String _statusFor(List<Rect>? regions) {
    if (regions == null) return 'Reserved Region 不可用';
    if (regions.isEmpty) return '当前没有激活的遮挡区域';
    return '检测到 ${regions.length} 个遮挡区域';
  }
}
```

Bridge 会在以下时机刷新数据：

- 首帧渲染完成后
- 窗口尺寸或 metrics 发生变化时
- 应用重新进入前台时

如果多个异步请求先后返回，Bridge 只接受最新一次请求的结果，避免旧结果覆盖新状态。

## 返回值语义

| 返回值 | 含义 |
| --- | --- |
| `null` | 当前平台或系统能力不可用，或者查询失败。应用应继续使用回退布局。 |
| `[]` | 查询成功，但当前没有激活的遮挡区域。 |
| 非空列表 | 当前激活的矩形，坐标为 Flutter 窗口逻辑坐标。 |

这些矩形是几何区域，不是可以直接套用的 padding。业务界面应将重要内容的窗口坐标边界
与这些矩形做重叠或相交判断，再决定移动距离或替代布局。

下面的辅助函数会计算内容矩形向下避开所有相交区域所需的距离：

```dart
double downwardClearance(Rect contentBounds, List<Rect> regions) {
  double clearance = 0;
  for (final Rect region in regions) {
    if (!contentBounds.overlaps(region)) continue;
    final double required = region.bottom - contentBounds.top;
    if (required > clearance) clearance = required;
  }
  return clearance;
}
```

如果目标内容位于 AppBar、Navigator 或其他发生过坐标变换的祖先组件下方，应先将边界转换为
窗口坐标。对于 `RenderBox`，可以使用 `localToGlobal(Offset.zero)` 获取窗口坐标原点。

## 直接查询

如果应用已经拥有自己的刷新生命周期，可以直接调用平台通道封装：

```dart
final List<Rect>? regions =
    await const TwIphoneDuoReservedRegionChannel().load();
```

大多数应用应优先使用 Bridge，因为它会处理必要的生命周期刷新，并将同一份结果共享给子树。

## 错误与回退

在非 iOS 平台上，插件不会调用 MethodChannel，而是直接返回 `null`。

以下情况会通过 `FlutterError.reportError` 报告，同时向业务层返回 `null`：

- 插件未注册或平台实现不可用
- 原生调用抛出 `PlatformException`
- 原生数据不是数组或矩形字段无效
- 坐标包含非有限值、负宽度或负高度
- 查询过程中出现其他异常

这种设计保证集成问题可被监控，同时不会中断应用的普通回退布局。

## 限制

- 返回结果只描述当前 Flutter View。
- 只有受支持的 iOS 版本和设备能够返回 Reserved Region。
- 插件只报告几何信息，不会自动移动或重排组件。
- 插件不会在不支持的设备或平台上模拟 Reserved Region。

更完整的数据流、生命周期和双包管理器结构请参阅
[架构与使用说明](docs/architecture.zh-CN.md)。

可运行示例位于 [`example/lib/main.dart`](example/lib/main.dart)，其中包含状态展示和
窗口坐标遮挡区域覆盖层。

## 问题反馈

请通过 [GitHub Issues](https://github.com/zeqinjie/tw_iphone_duo_reserved_region/issues)
反馈问题或兼容性信息。

## 许可证

本项目采用 [MIT License](LICENSE)。
