#!/bin/bash

# Batch YouTube Audio Downloader Script
# Downloads multiple YouTube videos as high-quality MP3 files

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp is not installed. Please install it first:"
    echo "pip install yt-dlp"
    echo "or: brew install yt-dlp"
    exit 1
fi

# Output directory (nujabes folder)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/../LofiTimer/Resources/Audio/music/nujabes"

# Create a URLs file if it doesn't exist
URLS_FILE="$SCRIPT_DIR/youtube_urls.txt"
if [ ! -f "$URLS_FILE" ]; then
    echo "Creating youtube_urls.txt file..."
    cat > "$URLS_FILE" << EOF
# Add YouTube URLs here, one per line
# Lines starting with # are comments and will be ignored
# Example:
# https://www.youtube.com/watch?v=RwtAEiruMYU
# https://www.youtube.com/watch?v=another_video_id

https://www.youtube.com/watch?v=RwtAEiruMYU
EOF
    echo "Please edit youtube_urls.txt and add your YouTube URLs, then run this script again."
    exit 0
fi

echo "🎵 Batch YouTube Audio Downloader"
echo "=================================="
echo "Output directory: $OUTPUT_DIR"
echo "Reading URLs from: $URLS_FILE"
echo ""

# Count total URLs (excluding comments and empty lines)
TOTAL_URLS=$(grep -v '^#' "$URLS_FILE" | grep -v '^$' | wc -l | tr -d ' ')
echo "Found $TOTAL_URLS URLs to download"
echo ""

# Read URLs and download each one
CURRENT=0
while IFS= read -r url; do
    # Skip comments and empty lines
    if [[ "$url" =~ ^#.*$ ]] || [[ -z "$url" ]]; then
        continue
    fi
    
    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL_URLS] Downloading: $url"
    
    # Download with highest quality audio settings
    yt-dlp \
        --extract-audio \
        --audio-format mp3 \
        --audio-quality 0 \
        --embed-metadata \
        --add-metadata \
        --output "$OUTPUT_DIR/%(uploader)s - %(title)s.%(ext)s" \
        --restrict-filenames \
        --no-playlist \
        --ignore-errors \
        --no-warnings \
        "$url"
    
    if [ $? -eq 0 ]; then
        echo "✅ Successfully downloaded"
    else
        echo "❌ Failed to download: $url"
    fi
    echo ""
done < "$URLS_FILE"

echo "🎉 Batch download completed!"
echo ""

# Show downloaded files
echo "📁 Downloaded MP3 files:"
ls -la "$OUTPUT_DIR"/*.mp3 2>/dev/null | while read -r line; do
    filename=$(echo "$line" | awk '{print $NF}')
    size=$(echo "$line" | awk '{print $5}')
    echo "  📄 $(basename "$filename") ($size bytes)"
done

echo ""
echo "💡 Tips:"
echo "1. Files are saved with highest quality (--audio-quality 0)"
echo "2. Metadata is embedded in the files"
echo "3. Filenames are sanitized for compatibility"
echo "4. You can now select 'Jazz' category in the app to play these tracks"
echo ""
echo "To add more URLs, edit: $URLS_FILE"