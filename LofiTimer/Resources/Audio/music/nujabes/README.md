# 🎵 Nujabes Music Collection

这个文件夹包含了Nujabes/Jazz-hip-hop风格的音乐，用于LoFi Timer应用。

## 📁 当前文件
- `nujabes-flowers.mp3` - 示例Nujabes风格音轨

## 🚀 快速开始

### 方法1：GUI下载器（推荐）
```bash
# 启动图形界面下载器
python3 youtube_downloader_gui.py
```

### 方法2：命令行批量下载
```bash
# 编辑URL列表然后运行
./batch_download.sh
```

### 方法3：单个下载
```bash
./download_youtube_audio.sh
```

## 🛠️ 可用工具

### 1. YouTube音频下载器 GUI
- **文件**: `youtube_downloader_gui.py`
- **功能**: 图形界面批量下载YouTube音频
- **特点**: 
  - 支持批量下载
  - 最高音质设置
  - 实时下载进度
  - 自动文件命名和元数据

### 2. 批量下载脚本
- **文件**: `batch_download.sh`
- **功能**: 命令行批量下载
- **配置**: 编辑 `youtube_urls.txt` 添加URL

### 3. MP3文件处理器
- **文件**: `process_mp3_files.py`
- **功能**: 批量处理已有的MP3文件
- **特点**:
  - 标准化文件名
  - 移除重复文件
  - 添加元数据
  - 音量标准化

## 📋 安装依赖

### 必需依赖
```bash
# 安装 yt-dlp (YouTube下载器)
pip install yt-dlp
# 或者使用 Homebrew
brew install yt-dlp
```

### 可选依赖
```bash
# 用于高级音频处理
brew install ffmpeg
pip install mutagen  # 元数据处理
```

## 🎯 使用流程

1. **下载音频**: 使用GUI或命令行工具下载YouTube音频
2. **处理文件**: 使用MP3处理器标准化文件名和元数据
3. **在应用中使用**: 在LoFi Timer中选择"Jazz"类别播放

## 🎨 推荐艺术家/风格
- Nujabes
- Fat Jon
- DJ Okawari
- Emancipator
- Blazo
- Uyama Hiroto
- Kondor
- L'indécis

## 📝 文件命名约定
为了最佳效果，建议使用描述性文件名：
- `artist-name-track-title.mp3`
- 例如: `nujabes-aruarian-dance.mp3`

应用会自动格式化这些名称以便显示。

## ⚖️ 版权声明
请确保您下载的音乐符合版权法律要求，仅用于个人、非商业用途。尊重音乐创作者的版权。

## 📞 故障排除
- **yt-dlp未找到**: 确保已正确安装 `pip install yt-dlp`
- **下载失败**: 检查网络连接和YouTube URL有效性
- **GUI无法启动**: 确保已安装Python 3和tkinter
- **音频文件未在应用中显示**: 重启应用或点击"跳到下一首"刷新音乐库