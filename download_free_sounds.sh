#!/bin/bash

echo "🎵 Free Sound Effects Generator"
echo "================================"
echo ""
echo "Since we need placeholder sounds, this script will create simple system sounds"
echo "You should replace these with proper sound effects later."
echo ""

EFFECTS_DIR="LofiTimer/Resources/Audio/effects"

# Create simple placeholder sounds using system commands
echo "Creating placeholder sounds..."

# Note: These are text files that indicate what sounds are needed
# You'll need to download actual sound files

cat > "$EFFECTS_DIR/timer_start_PLACEHOLDER.txt" << 'EOF'
TIMER START SOUND NEEDED
========================
Recommended: Soft chime or gentle bell
Duration: 0.5-1 second
Style: Calming, not jarring

Try these searches on freesound.org:
- "meditation bell"
- "soft chime"
- "gentle notification"
- "zen bell"

Or use system sound ID: 1103 (Tink)
EOF

cat > "$EFFECTS_DIR/timer_pause_PLACEHOLDER.txt" << 'EOF'
TIMER PAUSE SOUND NEEDED
========================
Recommended: Subtle click or soft beep
Duration: 0.3-0.5 seconds
Style: Minimal, clean

Try these searches on freesound.org:
- "soft click"
- "interface sound"
- "subtle beep"
- "menu select"

Or use system sound ID: 1104 (Tock)
EOF

cat > "$EFFECTS_DIR/session_change_PLACEHOLDER.txt" << 'EOF'
SESSION CHANGE SOUND NEEDED
============================
Recommended: Transition or sweep sound
Duration: 1-2 seconds
Style: Smooth transition

Try these searches on freesound.org:
- "wind chimes"
- "transition sweep"
- "ambient bell"
- "soft whoosh"

Or use system sound ID: 1013 (Rising)
EOF

echo "✅ Created placeholder files"
echo ""
echo "📥 Recommended free sound sources:"
echo ""
echo "1. Freesound.org (free account required)"
echo "   https://freesound.org/search/?q=notification+bell"
echo ""
echo "2. Mixkit (no account needed)"
echo "   https://mixkit.co/free-sound-effects/bell/"
echo ""
echo "3. Zapsplat (free account required)"
echo "   https://www.zapsplat.com/sound-effect-category/bells/"
echo ""
echo "4. Direct downloads (copy & paste in browser):"
echo "   • Soft Bell: https://mixkit.co/free-sound-effects/bell/"
echo "   • Click sounds: https://mixkit.co/free-sound-effects/click/"
echo ""
echo "📝 After downloading:"
echo "1. Rename files to: timer_start.mp3, timer_pause.mp3, session_change.mp3"
echo "2. Move them to: $EFFECTS_DIR/"
echo "3. Delete the PLACEHOLDER.txt files"
echo "4. Add them to Xcode project"

# Also create a simple HTML page with links
cat > "$EFFECTS_DIR/download_sounds.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Download Free Sounds</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 20px; }
        h2 { color: #333; }
        .sound-card { border: 1px solid #ddd; padding: 15px; margin: 10px 0; border-radius: 8px; }
        a { color: #007AFF; text-decoration: none; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>🎵 Free Sound Effects for LofiTimer</h1>
    
    <div class="sound-card">
        <h2>Timer Start Sound</h2>
        <p>Soft chime or gentle bell (0.5-1 second)</p>
        <ul>
            <li><a href="https://freesound.org/search/?q=meditation+bell" target="_blank">Search on Freesound</a></li>
            <li><a href="https://mixkit.co/free-sound-effects/bell/" target="_blank">Browse on Mixkit</a></li>
        </ul>
    </div>
    
    <div class="sound-card">
        <h2>Timer Pause Sound</h2>
        <p>Subtle click or soft beep (0.3-0.5 seconds)</p>
        <ul>
            <li><a href="https://freesound.org/search/?q=interface+click" target="_blank">Search on Freesound</a></li>
            <li><a href="https://mixkit.co/free-sound-effects/click/" target="_blank">Browse on Mixkit</a></li>
        </ul>
    </div>
    
    <div class="sound-card">
        <h2>Session Change Sound</h2>
        <p>Transition or sweep sound (1-2 seconds)</p>
        <ul>
            <li><a href="https://freesound.org/search/?q=wind+chimes" target="_blank">Search on Freesound</a></li>
            <li><a href="https://mixkit.co/free-sound-effects/transition/" target="_blank">Browse on Mixkit</a></li>
        </ul>
    </div>
    
    <div class="sound-card">
        <h2>Background Music</h2>
        <p>Lofi hip-hop tracks</p>
        <ul>
            <li><a href="https://www.youtube.com/audiolibrary" target="_blank">YouTube Audio Library</a></li>
            <li><a href="https://www.chosic.com/free-music/lofi/" target="_blank">Chosic - Free Lofi Music</a></li>
            <li><a href="https://pixabay.com/music/search/genre/beats/" target="_blank">Pixabay Music</a></li>
        </ul>
    </div>
</body>
</html>
EOF

echo ""
echo "💡 Tip: Open download_sounds.html in your browser for clickable links:"
echo "   open $EFFECTS_DIR/download_sounds.html"