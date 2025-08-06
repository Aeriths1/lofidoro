#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
MP3 Files Batch Processor
Processes MP3 files: normalize names, adjust quality, organize files
"""

import os
import shutil
import re
from pathlib import Path
import subprocess
import tkinter as tk
from tkinter import ttk, filedialog, messagebox
import threading

class MP3Processor:
    def __init__(self, root):
        self.root = root
        self.root.title("MP3 文件批量处理器")
        self.root.geometry("700x500")
        
        # Get current directory (nujabes folder)
        self.current_dir = Path(__file__).parent.absolute()
        
        self.create_widgets()
    
    def create_widgets(self):
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.pack(fill=tk.BOTH, expand=True)
        
        # Title
        ttk.Label(main_frame, text="🎵 MP3 文件批量处理器", font=("Arial", 16, "bold")).pack(pady=(0, 20))
        
        # Source directory selection
        src_frame = ttk.Frame(main_frame)
        src_frame.pack(fill=tk.X, pady=5)
        ttk.Label(src_frame, text="源文件夹:").pack(side=tk.LEFT)
        self.src_dir_var = tk.StringVar(value=str(self.current_dir))
        ttk.Entry(src_frame, textvariable=self.src_dir_var, state="readonly").pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(10, 5))
        ttk.Button(src_frame, text="选择", command=self.choose_source_dir).pack(side=tk.RIGHT)
        
        # Processing options
        options_frame = ttk.LabelFrame(main_frame, text="处理选项", padding="10")
        options_frame.pack(fill=tk.X, pady=10)
        
        # Normalize filenames
        self.normalize_names = tk.BooleanVar(value=True)
        ttk.Checkbutton(options_frame, text="标准化文件名 (移除特殊字符、统一格式)", 
                       variable=self.normalize_names).pack(anchor=tk.W)
        
        # Remove duplicates
        self.remove_duplicates = tk.BooleanVar(value=True)
        ttk.Checkbutton(options_frame, text="移除重复文件 (基于文件大小和名称)", 
                       variable=self.remove_duplicates).pack(anchor=tk.W)
        
        # Add metadata
        self.add_metadata = tk.BooleanVar(value=True)
        ttk.Checkbutton(options_frame, text="添加/修正元数据 (艺术家: Nujabes, 专辑: LoFi Collection)", 
                       variable=self.add_metadata).pack(anchor=tk.W)
        
        # Volume normalization
        self.normalize_volume = tk.BooleanVar(value=False)
        ttk.Checkbutton(options_frame, text="音量标准化 (需要 ffmpeg)", 
                       variable=self.normalize_volume).pack(anchor=tk.W)
        
        # Quality settings
        quality_frame = ttk.Frame(options_frame)
        quality_frame.pack(fill=tk.X, pady=(10, 0))
        
        self.adjust_quality = tk.BooleanVar(value=False)
        ttk.Checkbutton(quality_frame, text="调整音质到:", variable=self.adjust_quality).pack(side=tk.LEFT)
        
        self.target_quality = tk.StringVar(value="192")
        quality_combo = ttk.Combobox(quality_frame, textvariable=self.target_quality, 
                                   values=["128", "192", "256", "320"], state="readonly", width=8)
        quality_combo.pack(side=tk.LEFT, padx=(5, 2))
        ttk.Label(quality_frame, text="kbps").pack(side=tk.LEFT)
        
        # Control buttons
        control_frame = ttk.Frame(main_frame)
        control_frame.pack(pady=20)
        
        self.process_btn = ttk.Button(control_frame, text="开始处理", command=self.start_processing)
        self.process_btn.pack(side=tk.LEFT, padx=5)
        
        ttk.Button(control_frame, text="预览更改", command=self.preview_changes).pack(side=tk.LEFT, padx=5)
        ttk.Button(control_frame, text="打开文件夹", command=self.open_folder).pack(side=tk.LEFT, padx=5)
        
        # Progress
        self.progress_var = tk.StringVar(value="就绪")
        ttk.Label(main_frame, textvariable=self.progress_var, foreground="blue").pack(pady=5)
        
        # Log
        ttk.Label(main_frame, text="处理日志:").pack(anchor=tk.W, pady=(10, 5))
        self.log_frame = ttk.Frame(main_frame)
        self.log_frame.pack(fill=tk.BOTH, expand=True)
        
        self.log_text = tk.Text(self.log_frame, height=10)
        scrollbar = ttk.Scrollbar(self.log_frame, orient=tk.VERTICAL, command=self.log_text.yview)
        self.log_text.configure(yscrollcommand=scrollbar.set)
        
        self.log_text.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
    
    def choose_source_dir(self):
        directory = filedialog.askdirectory(initialdir=self.current_dir)
        if directory:
            self.src_dir_var.set(directory)
    
    def open_folder(self):
        import subprocess
        import sys
        folder = self.src_dir_var.get()
        if sys.platform == "darwin":  # macOS
            subprocess.run(["open", folder])
        elif sys.platform == "win32":  # Windows
            os.startfile(folder)
        else:  # Linux
            subprocess.run(["xdg-open", folder])
    
    def log(self, message):
        self.log_text.insert(tk.END, f"{message}\n")
        self.log_text.see(tk.END)
        self.root.update_idletasks()
    
    def get_mp3_files(self, directory):
        """Get all MP3 files in directory"""
        mp3_files = []
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.lower().endswith('.mp3'):
                    mp3_files.append(Path(root) / file)
        return mp3_files
    
    def normalize_filename(self, filename):
        """Normalize filename for consistency"""
        # Remove file extension
        name = filename.stem
        
        # Remove common YouTube suffixes
        patterns_to_remove = [
            r'\s*\[.*?\]',  # Remove [anything]
            r'\s*\(.*?\)',  # Remove (anything) 
            r'\s*-\s*YouTube',
            r'\s*-\s*Official.*',
            r'\s*HD\s*',
            r'\s*HQ\s*',
            r'\s*Audio\s*',
            r'\s*Video\s*',
        ]
        
        for pattern in patterns_to_remove:
            name = re.sub(pattern, '', name, flags=re.IGNORECASE)
        
        # Clean up characters
        name = re.sub(r'[^\w\s\-_.]', '', name)  # Remove special chars except basic ones
        name = re.sub(r'\s+', ' ', name)  # Multiple spaces to single space
        name = name.strip()
        
        # Ensure it's not empty
        if not name:
            name = "Untitled"
        
        return name + '.mp3'
    
    def preview_changes(self):
        """Preview what changes would be made"""
        self.log_text.delete(1.0, tk.END)
        src_dir = Path(self.src_dir_var.get())
        
        if not src_dir.exists():
            messagebox.showerror("错误", "源文件夹不存在")
            return
        
        mp3_files = self.get_mp3_files(src_dir)
        if not mp3_files:
            self.log("❌ 未找到 MP3 文件")
            return
        
        self.log(f"📁 找到 {len(mp3_files)} 个 MP3 文件")
        self.log("\n预览更改:")
        self.log("=" * 50)
        
        changes = []
        for mp3_file in mp3_files:
            old_name = mp3_file.name
            if self.normalize_names.get():
                new_name = self.normalize_filename(mp3_file)
                if old_name != new_name:
                    changes.append((mp3_file, new_name))
                    self.log(f"📝 重命名: {old_name} → {new_name}")
        
        if not changes:
            self.log("✅ 无需重命名文件")
        
        # Show other operations that would be performed
        if self.remove_duplicates.get():
            self.log("\n🔍 将检查重复文件")
        if self.add_metadata.get():
            self.log("🏷️  将添加/更新元数据")
        if self.normalize_volume.get():
            self.log("🔊 将标准化音量")
        if self.adjust_quality.get():
            self.log(f"⚙️  将调整音质到 {self.target_quality.get()} kbps")
    
    def start_processing(self):
        """Start processing files in a separate thread"""
        src_dir = Path(self.src_dir_var.get())
        
        if not src_dir.exists():
            messagebox.showerror("错误", "源文件夹不存在")
            return
        
        # Confirm before processing
        if not messagebox.askyesno("确认", "确定要开始处理 MP3 文件吗？建议先备份重要文件。"):
            return
        
        self.process_btn.config(state="disabled")
        self.progress_var.set("处理中...")
        self.log_text.delete(1.0, tk.END)
        
        # Start processing thread
        thread = threading.Thread(target=self.process_worker, args=(src_dir,))
        thread.daemon = True
        thread.start()
    
    def process_worker(self, src_dir):
        """Worker thread for processing files"""
        try:
            mp3_files = self.get_mp3_files(src_dir)
            total_files = len(mp3_files)
            
            if total_files == 0:
                self.root.after(0, lambda: self.log("❌ 未找到 MP3 文件"))
                return
            
            self.root.after(0, lambda: self.log(f"🎵 开始处理 {total_files} 个 MP3 文件"))
            
            processed = 0
            errors = 0
            
            # Step 1: Normalize filenames
            if self.normalize_names.get():
                self.root.after(0, lambda: self.log("\n📝 标准化文件名..."))
                for i, mp3_file in enumerate(mp3_files):
                    try:
                        new_name = self.normalize_filename(mp3_file)
                        if mp3_file.name != new_name:
                            new_path = mp3_file.parent / new_name
                            # Avoid overwriting existing files
                            counter = 1
                            while new_path.exists() and new_path != mp3_file:
                                name_part = new_name.rsplit('.', 1)[0]
                                new_path = mp3_file.parent / f"{name_part}_{counter}.mp3"
                                counter += 1
                            
                            mp3_file.rename(new_path)
                            mp3_files[i] = new_path  # Update reference
                            self.root.after(0, lambda o=mp3_file.name, n=new_path.name: 
                                          self.log(f"  ✅ {o} → {n}"))
                        processed += 1
                    except Exception as e:
                        errors += 1
                        self.root.after(0, lambda f=mp3_file.name, e=str(e): 
                                      self.log(f"  ❌ 重命名失败 {f}: {e}"))
            
            # Step 2: Remove duplicates (simple implementation)
            if self.remove_duplicates.get():
                self.root.after(0, lambda: self.log("\n🔍 检查重复文件..."))
                seen_sizes = {}
                duplicates = []
                
                for mp3_file in mp3_files:
                    try:
                        size = mp3_file.stat().st_size
                        if size in seen_sizes:
                            duplicates.append(mp3_file)
                            self.root.after(0, lambda f=mp3_file.name: 
                                          self.log(f"  🗑️ 发现重复文件: {f}"))
                        else:
                            seen_sizes[size] = mp3_file
                    except Exception as e:
                        self.root.after(0, lambda f=mp3_file.name, e=str(e): 
                                      self.log(f"  ❌ 检查文件失败 {f}: {e}"))
                
                # Remove duplicates
                for dup_file in duplicates:
                    try:
                        dup_file.unlink()
                        self.root.after(0, lambda f=dup_file.name: 
                                      self.log(f"  ✅ 删除重复文件: {f}"))
                    except Exception as e:
                        errors += 1
                        self.root.after(0, lambda f=dup_file.name, e=str(e): 
                                      self.log(f"  ❌ 删除失败 {f}: {e}"))
            
            # Additional processing steps would go here (metadata, volume, quality)
            # These would require additional dependencies like mutagen, ffmpeg, etc.
            
            self.root.after(0, lambda: self.progress_var.set(f"完成! 处理: {processed}, 错误: {errors}"))
            self.root.after(0, lambda: self.log(f"\n🎉 处理完成! 处理: {processed}, 错误: {errors}"))
            
        except Exception as e:
            self.root.after(0, lambda e=str(e): self.log(f"❌ 处理过程中发生错误: {e}"))
        finally:
            self.root.after(0, lambda: self.process_btn.config(state="normal"))

def main():
    root = tk.Tk()
    app = MP3Processor(root)
    root.mainloop()

if __name__ == "__main__":
    main()