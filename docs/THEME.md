# 主题系统

## 设计理念

采用 **GitHub Dark** 风格配色，深色模式为默认主题，同时提供浅色模式支持。遵循 Material 3 设计规范。

## 配色方案

### 深色模式（默认）

| Token | 色值 | 用途 |
|-------|------|------|
| `bgPrimary` | `#0D1117` | 页面背景 |
| `bgSecondary` | `#161B22` | 卡片、AppBar、底部导航栏 |
| `bgTertiary` | `#21262D` | 输入框、按钮背景 |
| `border` | `#30363D` | 分割线、边框 |
| `textPrimary` | `#E6EDF3` | 主标题、正文 |
| `textSecondary` | `#8B949E` | 副标题、说明文字 |
| `accent` | `#58A6FF` | 主色调、选中状态 |
| `accentHover` | `#79B8FF` | 悬停状态 |
| `txColor` | `#3FB950` | 发送数据标识 |
| `rxColor` | `#FF7B72` | 接收数据标识 |
| `warning` | `#D29922` | 警告提示 |
| `error` | `#F85149` | 错误提示 |

### 浅色模式

| Token | 色值 | 用途 |
|-------|------|------|
| `lightBgPrimary` | `#FFFFFF` | 页面背景 |
| `lightBgSecondary` | `#F6F8FA` | 卡片、AppBar |
| `lightBorder` | `#D0D7DE` | 分割线、边框 |
| `lightTextPrimary` | `#24292F` | 主标题、正文 |
| `lightTextSecondary` | `#57606A` | 副标题、说明文字 |
| `lightAccent` | `#0969DA` | 主色调 |

## 使用方式

```dart
// 应用级别（在 app.dart 中配置）
MaterialApp.router(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.dark,  // 默认深色
);

// 获取当前主题颜色
final colorScheme = Theme.of(context).colorScheme;
final primary = colorScheme.primary;

// 直接使用 AppColors
Container(color: AppColors.bgSecondary);
Text('Title', style: TextStyle(color: AppColors.textPrimary));
```

## 组件主题配置

| 组件 | 深色模式配置 |
|------|-------------|
| `AppBar` | `bgSecondary` 背景，`textPrimary` 文字，无阴影 |
| `BottomNavigationBar` | `bgSecondary` 背景，`accent` 选中色 |
| `Card` | `bgSecondary` 背景，圆角 8px，`border` 边框 |
| `InputDecoration` | `bgTertiary` 填充，`border` 默认边框，`accent` 聚焦边框 |
| `Divider` | `border` 颜色，1px 粗细 |

## 消息方向颜色

在日志和通信界面中，使用颜色区分收发方向：

```dart
Color getDirectionColor(String direction) {
  return direction == 'tx' ? AppColors.txColor : AppColors.rxColor;
}
```
