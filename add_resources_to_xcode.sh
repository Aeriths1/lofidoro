#!/bin/bash

echo "🔧 Adding resources to Xcode project..."

# Function to generate UUID
generate_uuid() {
    python3 -c "import uuid; print(uuid.uuid4().hex[:24].upper())"
}

# Backup project file
cp LofiTimer.xcodeproj/project.pbxproj LofiTimer.xcodeproj/project.pbxproj.backup
echo "✅ Created backup of project.pbxproj"

# Read the project file
PROJECT_FILE="LofiTimer.xcodeproj/project.pbxproj"

# Find the Resources group ID
RESOURCES_GROUP_ID="4F1A2B3C2B4D5E6F789012CB"
RESOURCES_BUILD_PHASE_ID="4F1A2B3C2B4D5E6F789012BD"

# Create temp file for modifications
TEMP_FILE=$(mktemp)

# Function to add a file to the project
add_file_to_project() {
    local file_path=$1
    local file_name=$2
    local file_ref_id=$(generate_uuid)
    local build_file_id=$(generate_uuid)
    
    echo "Adding $file_name..."
    
    # Add PBXBuildFile entry
    sed -i '' "/\* Begin PBXBuildFile section \*\//a\\
		${build_file_id} /* ${file_name} in Resources */ = {isa = PBXBuildFile; fileRef = ${file_ref_id} /* ${file_name} */; };
" "$PROJECT_FILE"
    
    # Add PBXFileReference entry
    sed -i '' "/\* Begin PBXFileReference section \*\//a\\
		${file_ref_id} /* ${file_name} */ = {isa = PBXFileReference; lastKnownFileType = ${3}; path = \"${file_path}\"; sourceTree = \"<group>\"; };
" "$PROJECT_FILE"
    
    # Add to Resources build phase
    sed -i '' "/files = (/a\\
				${build_file_id} /* ${file_name} in Resources */,
" "$PROJECT_FILE"
    
    return 0
}

# Add Audio folder structure
echo ""
echo "📁 Adding Audio folder to project..."

# Find all music files
echo "🎵 Adding music files..."
for category in nujabes kudasai zelda; do
    music_dir="LofiTimer/Resources/Audio/music/$category"
    if [ -d "$music_dir" ]; then
        for file in "$music_dir"/*.mp3; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                relative_path="Resources/Audio/music/$category/$filename"
                add_file_to_project "$relative_path" "$filename" "audio.mp3"
                echo "  ✅ Added: $filename"
            fi
        done
        for file in "$music_dir"/*.wav; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                relative_path="Resources/Audio/music/$category/$filename"
                add_file_to_project "$relative_path" "$filename" "audio.wav"
                echo "  ✅ Added: $filename"
            fi
        done
        for file in "$music_dir"/*.m4a; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                relative_path="Resources/Audio/music/$category/$filename"
                add_file_to_project "$relative_path" "$filename" "audio.m4a"
                echo "  ✅ Added: $filename"
            fi
        done
    fi
done

# Add effect sounds
echo ""
echo "🔊 Adding effect sounds..."
effects_dir="LofiTimer/Resources/Audio/effects"
if [ -d "$effects_dir" ]; then
    for file in "$effects_dir"/*.mp3; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            relative_path="Resources/Audio/effects/$filename"
            add_file_to_project "$relative_path" "$filename" "audio.mp3"
            echo "  ✅ Added: $filename"
        fi
    done
    for file in "$effects_dir"/*.wav; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            relative_path="Resources/Audio/effects/$filename"
            add_file_to_project "$relative_path" "$filename" "audio.wav"
            echo "  ✅ Added: $filename"
        fi
    done
fi

# Add GIF animations
echo ""
echo "🎞️ Adding GIF animations..."
animations_dir="LofiTimer/Resources/Animations"
if [ -d "$animations_dir" ]; then
    for file in "$animations_dir"/*.gif; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            relative_path="Resources/Animations/$filename"
            
            # Skip if already added
            if grep -q "$filename" "$PROJECT_FILE"; then
                echo "  ⏭️  Skipping (already added): $filename"
            else
                add_file_to_project "$relative_path" "$filename" "image.gif"
                echo "  ✅ Added: $filename"
            fi
        fi
    done
fi

echo ""
echo "📊 Summary of resources:"
echo -n "  Music files: "
find LofiTimer/Resources/Audio/music -name "*.mp3" -o -name "*.wav" -o -name "*.m4a" | wc -l
echo -n "  Effect sounds: "
find LofiTimer/Resources/Audio/effects -name "*.mp3" -o -name "*.wav" | wc -l
echo -n "  GIF animations: "
find LofiTimer/Resources/Animations -name "*.gif" | wc -l

echo ""
echo "✅ Resources added to Xcode project!"
echo ""
echo "⚠️  Important: After running this script:"
echo "1. Open the project in Xcode"
echo "2. Clean Build Folder (Shift+Cmd+K)"
echo "3. Build the project (Cmd+B)"
echo "4. The resources should now be available in the app bundle"