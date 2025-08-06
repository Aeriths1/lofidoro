#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
YouTube Audio Downloader GUI
Simple interface for downloading YouTube videos as high-quality MP3 files
"""

import tkinter as tk
from tkinter import ttk, scrolledtext, filedialog, messagebox
import subprocess
import threading
import os
import sys
from pathlib import Path

class YouTubeDownloaderGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("YouTube Audio Downloader - LoFi Timer")
        self.root.geometry("900x700")
        
        # Get the music directory path
        script_dir = Path(__file__).parent.absolute()
        self.music_dir = script_dir.parent / "LofiTimer" / "Resources" / "Audio" / "music"
        
        # Default to nujabes folder
        self.output_dir = self.music_dir / "nujabes"
        
        # Initialize variables
        self.is_downloading = False
        self.download_thread = None
        self.existing_categories = []
        
        self.create_widgets()
        self.load_existing_categories()
        self.check_dependencies()
    
    def load_existing_categories(self):
        """Load existing music categories from the music directory"""
        self.existing_categories = []
        if self.music_dir.exists():
            for item in self.music_dir.iterdir():
                if item.is_dir() and not item.name.startswith('.'):
                    self.existing_categories.append(item.name)
        
        # Update the category combobox
        if hasattr(self, 'category_combo'):
            self.category_combo['values'] = self.existing_categories
    
    def create_widgets(self):
        # Main frame with scrollbar
        canvas = tk.Canvas(self.root)
        scrollbar = ttk.Scrollbar(self.root, orient="vertical", command=canvas.yview)
        scrollable_frame = ttk.Frame(canvas)
        
        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
        main_frame = ttk.Frame(scrollable_frame, padding="15")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title
        title_label = ttk.Label(main_frame, text="🎵 YouTube Audio Downloader", 
                               font=("Arial", 16, "bold"))
        title_label.pack(pady=(0, 20))
        
        # Music category selection frame
        category_frame = ttk.LabelFrame(main_frame, text="选择音乐类别", padding="10")
        category_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Existing categories
        cat_select_frame = ttk.Frame(category_frame)
        cat_select_frame.pack(fill=tk.X, pady=(0, 10))
        
        ttk.Label(cat_select_frame, text="现有类别:").pack(side=tk.LEFT)
        self.category_var = tk.StringVar(value="nujabes")
        self.category_combo = ttk.Combobox(cat_select_frame, textvariable=self.category_var, 
                                          state="readonly", width=20)
        self.category_combo.pack(side=tk.LEFT, padx=(10, 5), fill=tk.X, expand=True)
        self.category_combo.bind("<<ComboboxSelected>>", self.on_category_selected)
        
        ttk.Button(cat_select_frame, text="刷新", command=self.load_existing_categories).pack(side=tk.RIGHT, padx=(5, 0))
        
        # New category creation
        new_cat_frame = ttk.Frame(category_frame)
        new_cat_frame.pack(fill=tk.X, pady=(5, 0))
        
        ttk.Label(new_cat_frame, text="新建类别:").pack(side=tk.LEFT)
        self.new_category_var = tk.StringVar()
        new_cat_entry = ttk.Entry(new_cat_frame, textvariable=self.new_category_var, width=20)
        new_cat_entry.pack(side=tk.LEFT, padx=(10, 5), fill=tk.X, expand=True)
        
        ttk.Button(new_cat_frame, text="创建并选择", command=self.create_new_category).pack(side=tk.RIGHT)
        
        # Output directory display
        dir_frame = ttk.Frame(category_frame)
        dir_frame.pack(fill=tk.X, pady=(10, 0))
        ttk.Label(dir_frame, text="输出目录:").pack(side=tk.LEFT)
        self.dir_var = tk.StringVar(value=str(self.output_dir))
        dir_entry = ttk.Entry(dir_frame, textvariable=self.dir_var, state="readonly")
        dir_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(10, 5))
        ttk.Button(dir_frame, text="浏览", command=self.choose_directory).pack(side=tk.RIGHT)
        
        # URLs input
        urls_frame = ttk.LabelFrame(main_frame, text="YouTube URLs", padding="10")
        urls_frame.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        ttk.Label(urls_frame, text="YouTube URLs (一行一个):").pack(anchor=tk.W, pady=(0, 5))
        self.urls_text = scrolledtext.ScrolledText(urls_frame, height=8, width=70)
        self.urls_text.pack(fill=tk.BOTH, expand=True, pady=(0, 5))
        
        # Add sample URL
        sample_url = "https://www.youtube.com/watch?v=RwtAEiruMYU"
        self.urls_text.insert("1.0", f"# 添加 YouTube URLs，一行一个\n# 以 # 开头的行为注释\n\n{sample_url}\n")
        
        # Quality and options
        options_frame = ttk.LabelFrame(main_frame, text="下载选项", padding="10")
        options_frame.pack(fill=tk.X, pady=(0, 10))
        
        # Quality settings
        quality_frame = ttk.Frame(options_frame)
        quality_frame.pack(fill=tk.X, pady=(0, 5))
        
        ttk.Label(quality_frame, text="音频质量:").pack(side=tk.LEFT)
        self.quality_var = tk.StringVar(value="best")
        quality_combo = ttk.Combobox(quality_frame, textvariable=self.quality_var, 
                                   values=["best", "320", "256", "192", "128"], state="readonly", width=10)
        quality_combo.pack(side=tk.LEFT, padx=(10, 5))
        ttk.Label(quality_frame, text="kbps (best = 最高质量)").pack(side=tk.LEFT)
        
        # Metadata options
        meta_frame = ttk.Frame(options_frame)
        meta_frame.pack(fill=tk.X, pady=(5, 0))
        
        self.embed_metadata = tk.BooleanVar(value=True)
        ttk.Checkbutton(meta_frame, text="嵌入元数据", variable=self.embed_metadata).pack(side=tk.LEFT)
        
        self.restrict_filenames = tk.BooleanVar(value=True)
        ttk.Checkbutton(meta_frame, text="安全文件名", variable=self.restrict_filenames).pack(side=tk.LEFT, padx=(20, 0))
        
        # Control buttons
        control_frame = ttk.Frame(main_frame)
        control_frame.pack(pady=15)
        
        self.download_btn = ttk.Button(control_frame, text="🚀 开始下载", command=self.start_download)
        self.download_btn.pack(side=tk.LEFT, padx=5)
        
        self.stop_btn = ttk.Button(control_frame, text="⏹ 停止下载", command=self.stop_download, state="disabled")
        self.stop_btn.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(control_frame, text="🗑 清空URLs", command=self.clear_urls).pack(side=tk.LEFT, padx=5)
        ttk.Button(control_frame, text="📁 打开输出文件夹", command=self.open_output_folder).pack(side=tk.LEFT, padx=5)
        
        # Progress and status
        progress_frame = ttk.Frame(main_frame)
        progress_frame.pack(fill=tk.X, pady=(0, 10))
        
        self.progress_var = tk.StringVar(value="就绪")
        ttk.Label(progress_frame, textvariable=self.progress_var, foreground="blue", font=("Arial", 10, "bold")).pack()
        
        # Log output
        log_frame = ttk.LabelFrame(main_frame, text="下载日志", padding="10")
        log_frame.pack(fill=tk.BOTH, expand=True)
        
        self.log_text = scrolledtext.ScrolledText(log_frame, height=8, width=70)
        self.log_text.pack(fill=tk.BOTH, expand=True)
    
    def on_category_selected(self, event=None):
        """Update output directory when category is selected"""
        selected_category = self.category_var.get()
        if selected_category:
            self.output_dir = self.music_dir / selected_category
            self.dir_var.set(str(self.output_dir))
    
    def create_new_category(self):
        """Create a new music category folder"""
        new_category = self.new_category_var.get().strip()
        if not new_category:
            messagebox.showwarning("警告", "请输入新类别名称")
            return
        
        # Validate category name
        if not new_category.replace("_", "").replace("-", "").isalnum():
            messagebox.showerror("错误", "类别名称只能包含字母、数字、下划线和连字符")
            return
        
        new_dir = self.music_dir / new_category
        
        # Check if already exists
        if new_dir.exists():
            messagebox.showwarning("警告", f"类别 '{new_category}' 已存在")
            self.category_var.set(new_category)
            self.on_category_selected()
            return
        
        # Create the directory
        try:
            new_dir.mkdir(parents=True, exist_ok=True)
            
            # Create a README file in the new category
            readme_content = f"""# {new_category.title()} Music Collection

这个文件夹包含了{new_category}风格的音乐，用于LoFi Timer应用。

## 添加音乐

将MP3、M4A或WAV格式的音频文件放在此文件夹中。
应用会自动检测并加载这些文件。

## 文件命名建议
- 使用描述性文件名：`artist-name-track-title.mp3`
- 避免特殊字符和空格
- 推荐格式：MP3 (128-320 kbps)
"""
            readme_path = new_dir / "README.md"
            readme_path.write_text(readme_content, encoding='utf-8')
            
            self.log(f"✅ 成功创建新类别: {new_category}")
            self.load_existing_categories()
            self.category_var.set(new_category)
            self.on_category_selected()
            self.new_category_var.set("")
            
        except Exception as e:
            messagebox.showerror("错误", f"创建类别失败: {e}")
            self.log(f"❌ 创建类别失败: {e}")
    
    def choose_directory(self):
        directory = filedialog.askdirectory(initialdir=self.music_dir)
        if directory:
            self.output_dir = Path(directory)
            self.dir_var.set(str(self.output_dir))
    
    def clear_urls(self):
        self.urls_text.delete("1.0", tk.END)
        self.urls_text.insert("1.0", "# 添加 YouTube URLs，一行一个\n# 以 # 开头的行为注释\n\n")
    
    def open_output_folder(self):
        if sys.platform == "darwin":  # macOS
            subprocess.run(["open", str(self.output_dir)])
        elif sys.platform == "win32":  # Windows
            os.startfile(str(self.output_dir))
        else:  # Linux
            subprocess.run(["xdg-open", str(self.output_dir)])
    
    def check_dependencies(self):
        """Check if yt-dlp is installed"""
        try:
            subprocess.run(["yt-dlp", "--version"], capture_output=True, check=True)
            self.log("✅ yt-dlp 已安装")
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.log("❌ yt-dlp 未安装")
            self.log("请安装 yt-dlp: pip install yt-dlp")
            self.log("或者: brew install yt-dlp")
            self.download_btn.config(state="disabled")
    
    def log(self, message):
        """Add message to log"""
        self.log_text.insert(tk.END, f"{message}\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()
    
    def get_urls(self):
        """Extract URLs from text widget"""
        text = self.urls_text.get("1.0", tk.END)
        urls = []
        for line in text.split('\n'):
            line = line.strip()
            if line and not line.startswith('#'):
                if 'youtube.com' in line or 'youtu.be' in line:
                    urls.append(line)
        return urls
    
    def start_download(self):
        """Start downloading in a separate thread"""
        urls = self.get_urls()
        if not urls:
            messagebox.showwarning("警告", "请至少添加一个 YouTube URL")
            return
        
        # Ensure output directory exists
        try:
            self.output_dir.mkdir(parents=True, exist_ok=True)
        except Exception as e:
            messagebox.showerror("错误", f"无法创建输出目录: {e}")
            return
        
        self.is_downloading = True
        self.download_btn.config(state="disabled")
        self.stop_btn.config(state="normal")
        self.progress_var.set(f"准备下载 {len(urls)} 个视频到 {self.output_dir.name} 类别...")
        self.log_text.delete("1.0", tk.END)
        
        # Start download thread
        self.download_thread = threading.Thread(target=self.download_worker, args=(urls,))
        self.download_thread.daemon = True
        self.download_thread.start()
    
    def stop_download(self):
        """Stop the download process"""
        self.is_downloading = False
        self.progress_var.set("正在停止下载...")
        self.log("用户取消下载")
    
    def download_worker(self, urls):
        """Worker thread for downloading"""
        try:
            total_urls = len(urls)
            successful = 0
            failed = 0
            
            for i, url in enumerate(urls, 1):
                if not self.is_downloading:
                    break
                
                self.root.after(0, lambda: self.progress_var.set(f"下载中 ({i}/{total_urls}): {url[:50]}..."))
                self.root.after(0, lambda u=url: self.log(f"[{i}/{total_urls}] 开始下载: {u}"))
                
                # Prepare yt-dlp command
                quality = "0" if self.quality_var.get() == "best" else self.quality_var.get()
                
                cmd = [
                    "yt-dlp",
                    "--extract-audio",
                    "--audio-format", "mp3",
                    "--audio-quality", quality,
                    "--output", f"{self.output_dir}/%(uploader)s - %(title)s.%(ext)s",
                    "--no-playlist",
                    "--ignore-errors",
                    url
                ]
                
                # Add metadata options
                if self.embed_metadata.get():
                    cmd.extend(["--embed-metadata", "--add-metadata"])
                
                if self.restrict_filenames.get():
                    cmd.append("--restrict-filenames")
                
                try:
                    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
                    if result.returncode == 0:
                        successful += 1
                        self.root.after(0, lambda: self.log("✅ 下载成功"))
                    else:
                        failed += 1
                        error_msg = result.stderr[:100] if result.stderr else "未知错误"
                        self.root.after(0, lambda e=error_msg: self.log(f"❌ 下载失败: {e}"))
                except subprocess.TimeoutExpired:
                    failed += 1
                    self.root.after(0, lambda: self.log("❌ 下载超时"))
                except Exception as e:
                    failed += 1
                    self.root.after(0, lambda e=str(e): self.log(f"❌ 错误: {e}"))
        
        finally:
            # Reset UI state
            self.root.after(0, self._download_finished, successful, failed)
    
    def _download_finished(self, successful, failed):
        """Called when download is finished"""
        self.is_downloading = False
        self.download_btn.config(state="normal")
        self.stop_btn.config(state="disabled")
        
        total = successful + failed
        category_name = self.output_dir.name
        self.progress_var.set(f"完成! 类别: {category_name}, 成功: {successful}, 失败: {failed}")
        self.log(f"\n🎉 下载完成! 总计: {total}, 成功: {successful}, 失败: {failed}")
        self.log(f"📁 文件保存在: {self.output_dir}")
        
        if successful > 0:
            self.log(f"💡 现在可以在 LoFi Timer 应用中选择 '{category_name}' 类别来播放这些音乐")

def main():
    root = tk.Tk()
    app = YouTubeDownloaderGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()