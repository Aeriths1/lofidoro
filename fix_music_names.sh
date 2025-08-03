#!/bin/bash

echo "🎵 Fixing music file names..."
echo ""

# Fix Zelda folder
cd LofiTimer/Resources/Audio/music/zelda/ 2>/dev/null
if [ -f "Relaxing Zelda Music with Campfire Ambience.mp3" ]; then
    echo "Renaming Zelda file..."
    mv "Relaxing Zelda Music with Campfire Ambience.mp3" "zelda-campfire-ambience.mp3"
    echo "✅ Renamed to: zelda-campfire-ambience.mp3"
fi
cd - > /dev/null

# Fix Kudasai folder  
cd LofiTimer/Resources/Audio/music/kudasai/ 2>/dev/null
if [ -f "lofi-background.mp3" ]; then
    echo "Renaming Kudasai file..."
    mv "lofi-background.mp3" "kudasai-lofi-background.mp3"
    echo "✅ Renamed to: kudasai-lofi-background.mp3"
fi
cd - > /dev/null

echo ""
echo "📁 Current music structure:"
echo ""

for category in nujabes kudasai zelda; do
    echo "🎵 $category:"
    count=$(ls -1 LofiTimer/Resources/Audio/music/$category/*.mp3 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
        ls -1 LofiTimer/Resources/Audio/music/$category/*.mp3 2>/dev/null | while read file; do
            filename=$(basename "$file")
            size=$(du -h "$file" | cut -f1)
            echo "  ✓ $filename ($size)"
        done
    else
        echo "  ✗ No music files found"
    fi
    echo ""
done

echo "🔍 Checking MusicManager scanning..."
echo ""
echo "The MusicManager looks for files in these locations:"
echo "1. Bundle.main.resourcePath/music/<category>/"
echo "2. Files with category prefix in main bundle"
echo ""
echo "⚠️  IMPORTANT: You need to add these files to Xcode!"
echo ""
echo "Steps to fix:"
echo "1. Open LofiTimer.xcodeproj in Xcode"
echo "2. Right-click on LofiTimer folder"
echo "3. Select 'Add Files to LofiTimer...'"
echo "4. Navigate to Resources/Audio/music/"
echo "5. Select all the music folders (nujabes, kudasai, zelda)"
echo "6. Make sure:"
echo "   ✓ 'Copy items if needed' is UNCHECKED (files already exist)"
echo "   ✓ 'Create folder references' is selected (keeps folder structure)"
echo "   ✓ 'LofiTimer' target is selected"
echo "7. Click 'Add'"
echo ""
echo "The folders should appear as BLUE folders in Xcode (not yellow groups)"