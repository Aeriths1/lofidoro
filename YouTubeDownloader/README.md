# 🎵 YouTube Music Downloader

专为LoFi Timer应用设计的YouTube音频下载工具集。

## 🚀 快速开始

### 启动GUI下载器（推荐）
```bash
cd YouTubeDownloader
python3 youtube_downloader_gui.py
```

## ✨ 主要功能

### 🎯 智能音乐分类
- **自动检测现有类别**: 扫描并显示`LofiTimer/Resources/Audio/music/`下的所有音乐文件夹
- **新建类别**: 可以创建新的音乐类别文件夹（如：ambient、jazz-fusion、chill-hop等）
- **动态选择**: 选择不同类别下载音频到对应文件夹

### 📱 用户友好界面
- **批量下载**: 支持多个YouTube URL同时下载
- **实时进度**: 显示下载进度和状态
- **音质选择**: 支持不同音频质量（best/320/256/192/128 kbps）
- **元数据处理**: 自动嵌入音频元数据

### 🎵 现有音乐类别
当前支持的音乐类别：
- **nujabes** - Jazz hip-hop风格
- **kudasai** - 现代LoFi吉他
- **zelda** - 游戏音乐风格
- **whitenoise** - 白噪音/环境音

### 🆕 创建新类别
1. 在GUI中点击"新建类别"
2. 输入类别名称（只能包含字母、数字、下划线、连字符）
3. 点击"创建并选择"
4. 系统会自动创建文件夹和说明文档

## 📋 安装要求

### 必需依赖
```bash
# Python 3.6+
python3 --version

# yt-dlp (YouTube下载器)
pip install yt-dlp
# 或使用 Homebrew
brew install yt-dlp
```

### 可选依赖
```bash
# ffmpeg (用于高级音频处理)
brew install ffmpeg
# 或
sudo apt install ffmpeg
```

## 🎯 使用流程

1. **启动下载器**: 运行 `python3 youtube_downloader_gui.py`
2. **选择类别**: 选择现有类别或创建新类别
3. **添加URLs**: 在文本框中添加YouTube链接
4. **设置选项**: 选择音质和其他下载选项
5. **开始下载**: 点击"🚀 开始下载"
6. **在应用中使用**: 在LoFi Timer中选择对应类别播放

## 📁 文件结构

```
YouTubeDownloader/
├── youtube_downloader_gui.py      # GUI下载器
├── batch_download.sh              # 批量下载脚本
├── process_mp3_files.py           # MP3处理器
├── download_youtube_audio.sh      # 单个下载脚本
├── DOWNLOAD_INSTRUCTIONS.md       # 详细说明
└── README.md                      # 本文件

LofiTimer/Resources/Audio/music/
├── nujabes/                       # Jazz hip-hop
├── kudasai/                      # 现代LoFi
├── zelda/                        # 游戏音乐
├── whitenoise/                   # 白噪音
└── [新创建的类别]/                # 用户自定义类别
```

## 🛠️ 高级功能

### 批量处理工具
```bash
# 启动MP3处理器（文件名标准化、去重、元数据等）
python3 process_mp3_files.py
```

### 命令行工具
```bash
# 单个下载
./download_youtube_audio.sh

# 批量下载（需要先编辑youtube_urls.txt）
./batch_download.sh
```

## 🎵 与LoFi Timer集成

下载完成后，音频文件会自动被LoFi Timer应用检测：

1. **重启应用**或点击"跳到下一首"刷新音乐库
2. **选择音乐类别**：在设置中选择对应的类别
3. **自动播放**：新下载的音频会出现在播放列表中

## 🔧 故障排除

### yt-dlp相关
- **未找到yt-dlp**: `pip install yt-dlp` 或 `brew install yt-dlp`
- **下载速度慢**: 尝试更换网络或使用代理
- **某些视频无法下载**: 可能有地区限制或版权保护

### GUI界面
- **界面启动失败**: 确保Python 3.6+和tkinter已安装
- **类别不显示**: 检查LoFi Timer项目路径是否正确
- **下载失败**: 查看下载日志中的错误信息

### 音频质量
- **文件太大**: 选择较低的音质设置（192kbps通常足够）
- **音质不佳**: 选择"best"或"320"获得最高质量

## ⚖️ 使用须知

**重要**: 请遵守以下条款：
- **版权法律**: 仅下载您有权使用的内容
- **YouTube服务条款**: 遵守YouTube的使用条款  
- **个人使用**: 仅用于个人、非商业用途
- **尊重创作者**: 考虑支持原创音乐人

## 🎉 享受你的音乐！

现在你可以轻松下载喜欢的YouTube音频，并在LoFi Timer中享受高质量的背景音乐了！🎧