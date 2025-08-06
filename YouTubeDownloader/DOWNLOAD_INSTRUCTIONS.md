# YouTube 音频下载说明

## 📋 前提条件

在下载音频之前，您需要安装 `yt-dlp`：

### 方法1：使用 pip 安装
```bash
pip install yt-dlp
```

### 方法2：使用 Homebrew 安装（推荐 macOS 用户）
```bash
brew install yt-dlp
```

## 🚀 使用方法

### 自动下载指定视频
```bash
cd /path/to/LofiTimer/Resources/Audio/music/nujabes
./download_youtube_audio.sh
```

### 下载其他 YouTube 视频
如果你想下载其他视频，可以编辑脚本中的 URL：

```bash
# 编辑脚本
nano download_youtube_audio.sh

# 修改这一行：
YOUTUBE_URL="https://www.youtube.com/watch?v=你的视频ID"
```

### 手动下载命令
你也可以直接使用 yt-dlp 命令：

```bash
yt-dlp --extract-audio --audio-format mp3 --audio-quality 192K "https://www.youtube.com/watch?v=RwtAEiruMYU"
```

## 📁 文件放置

下载的音频文件会自动保存到当前的 `nujabes` 文件夹中。应用会自动检测并加载这些文件。

## ⚖️ 法律声明

**重要**: 请确保您遵守以下条款：

1. **版权法律**: 仅下载您有权使用的内容
2. **YouTube服务条款**: 遵守YouTube的使用条款
3. **个人使用**: 仅用于个人、非商业用途
4. **尊重创作者**: 考虑支持原创音乐人

## 🎵 应用中使用

下载完成后：

1. 重启应用或点击"跳到下一首"刷新音乐库
2. 在设置中选择"Jazz"类别
3. 新下载的音频将会出现在播放列表中

## 🔧 故障排除

### yt-dlp 未找到
```bash
# 检查是否安装
which yt-dlp

# 如果未安装，使用以下命令之一：
pip install yt-dlp
# 或
brew install yt-dlp
```

### 下载失败
- 检查网络连接
- 确认 YouTube URL 是否正确
- 有些视频可能有地区限制或版权保护

### 音频文件未在应用中出现
- 确保文件是 .mp3 格式
- 检查文件是否在正确的 `nujabes` 文件夹中
- 重启应用以刷新音乐库

## 📞 支持

如果遇到技术问题，请检查：
1. 文件权限是否正确
2. 音频文件格式是否支持（MP3、M4A、WAV）
3. 文件名是否包含特殊字符（脚本会自动处理）