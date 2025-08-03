#!/bin/bash

echo "🎵 Fixing audio file structure..."

# Fix file names with spaces
cd LofiTimer/Resources/Audio/music/nujabes/ 2>/dev/null
if [ -f "Nujabes - flowers [Official Audio].mp3" ]; then
    echo "Renaming Nujabes file..."
    mv "Nujabes - flowers [Official Audio].mp3" "nujabes-flowers.mp3"
    echo "✅ Renamed to: nujabes-flowers.mp3"
fi
cd - > /dev/null

# Check for old Audio folder
if [ -d "LofiTimer/Audio" ]; then
    echo "⚠️  Old Audio folder still exists at LofiTimer/Audio"
    echo "Moving any remaining files..."
    
    # Move any remaining mp3 files
    for file in LofiTimer/Audio/*.mp3; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo "Moving $filename to effects folder..."
            mv "$file" "LofiTimer/Resources/Audio/effects/"
        fi
    done
    
    # Try to remove old folder
    rmdir LofiTimer/Audio 2>/dev/null && echo "✅ Removed old Audio folder"
fi

# Create placeholder sound effects
echo ""
echo "📝 Creating placeholder info for missing sound effects..."

cat > LofiTimer/Resources/Audio/effects/NEEDED_EFFECTS.txt << 'EOF'
NEEDED SOUND EFFECTS
===================

Please add these sound effect files:

1. timer_start.mp3
   - A gentle chime or soft bell sound
   - Duration: 0.5-1 second
   - Example: Soft "ding" or meditation bell

2. timer_pause.mp3
   - A subtle click or soft tone
   - Duration: 0.3-0.5 seconds
   - Example: Soft "click" or muted beep

3. session_change.mp3
   - A transition sound between work/break
   - Duration: 1-2 seconds
   - Example: Wind chime or soft sweep

Currently available:
✅ timer_complete.mp3

Free sound sources:
- https://freesound.org
- https://www.zapsplat.com
- https://mixkit.co/free-sound-effects/
EOF

# Show current structure
echo ""
echo "📁 Current audio structure:"
echo ""
echo "Resources/Audio/"
echo "├── music/"
echo "│   ├── nujabes/"
ls -1 LofiTimer/Resources/Audio/music/nujabes/*.mp3 2>/dev/null | while read file; do
    echo "│   │   └── $(basename "$file")"
done
echo "│   ├── kudasai/ (empty - add tracks)"
echo "│   └── zelda/ (empty - add tracks)"
echo "└── effects/"
ls -1 LofiTimer/Resources/Audio/effects/*.mp3 2>/dev/null | while read file; do
    echo "    └── $(basename "$file")"
done

echo ""
echo "✅ Audio structure fixed!"
echo ""
echo "Next steps:"
echo "1. Add the missing sound effects to Resources/Audio/effects/"
echo "2. Add more music tracks using: ./add_music.sh <category> <file>"
echo "3. In Xcode, make sure all audio files are added to the project target"