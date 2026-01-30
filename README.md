# 电池监测应用 (Battery Monitor)

## 项目简介

这是一个用于MCM Problem A的Flutter应用，旨在实时采集智能手机的电池使用数据，包括：

- 电池电量和状态
- 屏幕亮度
- 网络类型和状态
- 设备信息
- 使用场景

数据将存储在本地SQLite数据库中，并可导出为CSV格式用于后续的数学建模分析。

## 环境搭建

### 1. 安装Flutter SDK

1. 访问 [Flutter官网](https://flutter.dev/docs/get-started/install/windows) 下载最新的Flutter SDK
2. 解压到任意目录（例如：`C:\flutter`）
3. 将Flutter的bin目录添加到系统环境变量PATH中
4. 运行 `flutter doctor` 检查环境配置

### 2. 安装Android Studio

1. 运行本项目根目录下的 `android-studio.exe` 安装程序
2. 按照提示完成安装，确保安装Flutter和Dart插件
3. 配置Android SDK和模拟器（可选）

### 3. 配置iOS开发环境

由于您使用的是Windows系统，我们将使用 **云编译** 的方式构建iOS应用：

1. 注册 [苹果开发者账号](https://developer.apple.com/)（年费99美元）
2. 注册 [CodeMagic账号](https://codemagic.io/)（免费版即可）
3. 创建 [GitHub仓库](https://github.com/) 并将本项目代码上传

## 项目配置

### 1. 安装依赖

在项目根目录运行：

```bash
flutter pub get
```

### 2. 配置iOS权限

项目已在 `ios/Runner/Info.plist` 中配置了所需的权限，包括：
- 位置服务（用于网络信息）
- 蓝牙（用于设备状态监测）
- 相册（用于数据导出）

## 运行项目

### 1. 在Android设备上运行

```bash
flutter run
```

### 2. 在iOS设备上运行

1. **上传代码到GitHub**：
   - 将本项目代码推送到您的GitHub仓库

2. **配置CodeMagic**：
   - 登录CodeMagic账号
   - 连接您的GitHub仓库
   - 选择本项目
   - 配置构建参数：
     - 选择 `iOS` 平台
     - 上传您的苹果开发者账号证书和描述文件

3. **构建并分发**：
   - 触发构建
   - 构建完成后，使用TestFlight分发到您的苹果手机

4. **安装应用**：
   - 在您的苹果手机上安装TestFlight应用
   - 接受TestFlight邀请并安装本应用

## 应用使用

### 1. 首次启动

- 应用会自动请求必要的权限
- 初始化本地数据库

### 2. 数据采集

1. **选择使用场景**：从下拉菜单中选择当前的使用场景（游戏、视频、通话等）
2. **开始采集**：点击「开始采集」按钮，应用会每10秒采集一次数据
3. **停止采集**：点击「停止采集」按钮结束数据采集

### 3. 数据导出

- 点击「导出为CSV」按钮，应用会将采集的数据导出为CSV文件
- 导出的文件会保存在应用的 `exports` 目录中

## 数据格式

导出的CSV文件包含以下字段：

| 字段 | 描述 |
|------|------|
| ID | 记录ID |
| Timestamp | 采集时间戳 |
| Scene | 使用场景 |
| Battery Level (%) | 电池电量百分比 |
| Battery State | 电池状态（充电中、放电中等） |
| Screen Brightness | 屏幕亮度 |
| Network Type | 网络类型（WiFi、移动网络等） |
| IP Address | IP地址 |
| Device Model | 设备型号 |
| System Version | 系统版本 |

## 注意事项

1. **iOS API限制**：
   - 无法直接读取所有后台应用
   - 电池温度采集可能受限于iOS API

2. **数据一致性**：
   - 采集时请保持其他条件稳定，仅改变您要测试的变量

3. **MCM报告关联**：
   - 在报告中说明数据采集的方法、频率和误差来源
   - 附上原始数据示例以增强报告的可信度

## 技术支持

如果遇到任何问题，请参考：
- [Flutter官方文档](https://flutter.dev/docs)
- [CodeMagic文档](https://docs.codemagic.io/)
- [苹果开发者文档](https://developer.apple.com/documentation/)

## 许可证

本项目仅供MCM比赛使用，请勿用于商业用途。