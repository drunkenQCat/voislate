# VoiSlate

## 克隆项目

要开始开发，首先需要将项目克隆到本地：

```bash
git clone https://github.com/your_username/voislate.git
cd voislate
```

## 安装依赖

克隆项目后，您需要安装 Flutter 和 Android SDK 环境以运行该项目。请确保您的开发环境已配置好以下内容：

1. **Flutter SDK**
2. **Dart SDK**
3. **Android Studio 或其他 Android 开发工具**

安装 Flutter 依赖：

```bash
flutter pub get
```

## 运行项目

要在本地运行该项目：

### 1. 启动 Android 模拟器或连接物理设备
确保已经启动 Android 模拟器或将设备通过 USB 连接到电脑。

### 2. 运行项目
使用 Flutter 命令启动应用：

```bash
flutter run
```

或者通过 Android Studio 运行项目，点击 "Run" 按钮。

### 3. 打包 Android APK
如需打包 Android APK 文件：

```bash
flutter build apk
```

打包完成后， APK 文件将生成在 `build/app/outputs/flutter-apk/` 目录中。

## 构建与发布

1. **Debug 模式构建：**
   ```bash
   flutter build apk --debug
   ```

2. **Release 模式构建：**
   ```bash
   flutter build apk --release
   ```

3. **调试运行：**
   您可以通过 `flutter run` 命令直接在模拟器或设备上调试应用。

## 目录结构说明

以下是项目的目录结构及说明：

```plaintext
src
├── build.yaml                    # 构建配置文件
├── pubspec.lock                   # 依赖锁文件
├── pubspec.yaml                   # 依赖和项目描述文件
├── analysis_options.yaml          # 静态分析选项
├── README.md                      # 项目说明文档
├── lib                            # 核心代码目录
│   ├── main.dart                  # 应用入口
│   ├── providers                  # 状态管理相关文件
│   ├── data                       # 数据文件及示例
│   ├── widgets                    # UI 组件
│   ├── pages                      # 应用页面
│   ├── helper                     # 辅助类和工具
│   ├── models                     # 数据模型定义
│   └── assets                     # 静态资源文件
├── android                        # Android 平台相关文件
│   ├── app                        # Android 应用配置
│   └── gradle                     # Gradle 配置
├── .gitignore                     # Git 忽略文件
└── .metadata                      # 项目元数据
```

### 关键目录说明

- **lib/providers**: 状态管理文件（如状态通知器）。
- **lib/data**: 包含示例数据和配置。
- **lib/widgets**: UI 组件和录音、场记相关的页面。
- **lib/pages**: 项目的核心页面代码。
- **lib/models**: 录音文件、场记、排期等数据模型。
- **lib/assets**: 图片等静态资源。
