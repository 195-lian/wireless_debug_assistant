# 构建与发布指南

## 环境要求

| 工具 | 版本 |
|------|------|
| Flutter | 3.41.7+ |
| Dart | 3.11.5+ |
| Android SDK | API 36 |
| Android NDK | 25.1.8937393 或 26.1.10909125 |
| AGP | 8.6.0 |
| Kotlin | 2.1.0 |
| Gradle | 8.14 |
| Java | 17 |

## 初始化项目

```bash
flutter pub get
```

## 构建 Debug APK

```bash
flutter build apk --debug
```

输出：`build/app/outputs/flutter-apk/app-debug.apk`

## 构建 Release APK

```bash
flutter build apk --release
```

输出：`build/app/outputs/flutter-apk/app-release.apk`

## 构建 App Bundle（Google Play 上架）

```bash
flutter build appbundle --release
```

输出：`build/app/outputs/bundle/release/app-release.aab`

## 签名配置

Release 构建需要配置签名。在 `android/app/build.gradle` 中：

```gradle
android {
    signingConfigs {
        release {
            storeFile file("release.keystore")
            storePassword System.getenv("STORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## 构建问题排查

### AGP / Kotlin 版本警告

当前配置：
- `android/settings.gradle` 中 `com.android.application` 版本 `8.6.0`
- `org.jetbrains.kotlin.android` 版本 `2.1.0`

### NDK 版本不匹配

部分插件硬编码了 NDK 版本（如 `jni` 插件要求 `25.1.8937393`）。如果报错 `CMAKE_C_COMPILER not set`，请通过 sdkmanager 安装对应版本的完整 NDK：

```bash
sdkmanager "ndk;25.1.8937393"
sdkmanager "ndk;26.1.10909125"
```

### Gradle 下载慢

在 `~/.gradle/gradle.properties` 中配置国内镜像：

```properties
systemProp.http.proxyHost=127.0.0.1
systemProp.http.proxyPort=7890
systemProp.https.proxyHost=127.0.0.1
systemProp.https.proxyPort=7890
```

## 安装到设备

```bash
# 连接设备后
flutter devices
flutter install

# 或指定设备
flutter install -d <device-id>
```

## 热重载开发

```bash
flutter run --debug
```

按 `r` 热重载，按 `R` 热重启。
