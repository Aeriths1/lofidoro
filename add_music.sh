#!/bin/bash

# Script to add music files to the LofiTimer project
# Usage: ./add_music.sh category path/to/your/music.mp3

if [ $# -lt 2 ]; then
    echo "Usage: $0 <category> <path/to/music.mp3>"
    echo ""
    echo "Categories:"
    echo "  nujabes - Jazz-influenced hip-hop beats"
    echo "  kudasai - Modern lofi with guitar"
    echo "  zelda   - Gaming lofi remixes"
    echo ""
    echo "Example: $0 nujabes ~/Downloads/aruarian-dance.mp3"
    exit 1
fi

CATEGORY="$1"
MUSIC_PATH="$2"
MUSIC_NAME=$(basename "$MUSIC_PATH")
DESTINATION="LofiTimer/Resources/Audio/music/$CATEGORY/"

# Validate category
if [[ ! "$CATEGORY" =~ ^(nujabes|kudasai|zelda)$ ]]; then
    echo "Error: Invalid category '$CATEGORY'"
    echo "Valid categories: nujabes, kudasai, zelda"
    exit 1
fi

# Check if source file exists
if [ ! -f "$MUSIC_PATH" ]; then
    echo "Error: File '$MUSIC_PATH' not found"
    exit 1
fi

# Check if it's an audio file
if [[ ! "$MUSIC_NAME" =~ \.(mp3|m4a|wav)$ ]]; then
    echo "Error: File must be .mp3, .m4a, or .wav"
    exit 1
fi

# Check if destination directory exists
if [ ! -d "$DESTINATION" ]; then
    echo "Error: Destination directory '$DESTINATION' not found"
    echo "Make sure you're running this script from the project root directory"
    exit 1
fi

# Copy the music file
echo "Adding $MUSIC_NAME to $CATEGORY category..."
cp "$MUSIC_PATH" "$DESTINATION"

if [ $? -eq 0 ]; then
    echo "✅ Successfully added $MUSIC_NAME to $CATEGORY"
    echo ""
    echo "Next steps:"
    echo "1. Open LofiTimer.xcodeproj in Xcode"
    echo "2. Right-click on Resources/Audio/music/$CATEGORY folder"
    echo "3. Select 'Add Files to LofiTimer...'"
    echo "4. Select $MUSIC_NAME and click 'Add'"
    echo "5. Make sure 'Copy items if needed' is checked"
    echo "6. Make sure 'LofiTimer' target is selected"
    echo "7. Build and run the app"
    echo ""
    echo "The music will automatically appear in the Music Settings!"
else
    echo "❌ Failed to copy the file"
    exit 1
fi