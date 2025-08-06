#!/bin/bash

# YouTube Audio Downloader Script for Nujabes music
# This script helps you download audio from YouTube for personal use only

# NOTE: Please ensure you comply with YouTube's Terms of Service and copyright laws
# Only download music you have the right to use

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp is not installed. Installing..."
    echo "You can install it with: pip install yt-dlp"
    echo "Or with Homebrew: brew install yt-dlp"
    exit 1
fi

# YouTube URL (replace with your desired URL)
YOUTUBE_URL="https://www.youtube.com/watch?v=RwtAEiruMYU"

# Output directory (current nujabes folder)
OUTPUT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Downloading audio from: $YOUTUBE_URL"
echo "Output directory: $OUTPUT_DIR"

# Download audio only, convert to MP3, and save in current directory
yt-dlp \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 192K \
    --output "$OUTPUT_DIR/%(title)s.%(ext)s" \
    --restrict-filenames \
    --no-playlist \
    "$YOUTUBE_URL"

echo "Download completed!"
echo "The audio file has been saved to the nujabes music folder."
echo "You can now select the Nujabes category in the app to play this music."

# List downloaded files
echo "Files in nujabes folder:"
ls -la "$OUTPUT_DIR"/*.mp3 2>/dev/null || echo "No MP3 files found."