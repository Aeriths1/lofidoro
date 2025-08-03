#!/bin/bash

# Script to add a GIF file to the LofiTimer project
# Usage: ./add_gif.sh path/to/your/gif.gif

if [ $# -eq 0 ]; then
    echo "Usage: $0 path/to/your/gif.gif"
    echo "Example: $0 ~/Downloads/cozy-room.gif"
    exit 1
fi

GIF_PATH="$1"
GIF_NAME=$(basename "$GIF_PATH")
DESTINATION="LofiTimer/Resources/Animations/"

# Check if source file exists
if [ ! -f "$GIF_PATH" ]; then
    echo "Error: File '$GIF_PATH' not found"
    exit 1
fi

# Check if it's a GIF file
if [[ ! "$GIF_NAME" =~ \.gif$ ]]; then
    echo "Error: File must have .gif extension"
    exit 1
fi

# Check if destination directory exists
if [ ! -d "$DESTINATION" ]; then
    echo "Error: Destination directory '$DESTINATION' not found"
    echo "Make sure you're running this script from the project root directory"
    exit 1
fi

# Copy the GIF file
echo "Copying $GIF_NAME to $DESTINATION..."
cp "$GIF_PATH" "$DESTINATION"

if [ $? -eq 0 ]; then
    echo "✅ Successfully added $GIF_NAME to the project"
    echo ""
    echo "Next steps:"
    echo "1. Open LofiTimer.xcodeproj in Xcode"
    echo "2. Right-click on Resources/Animations folder"
    echo "3. Select 'Add Files to LofiTimer...'"
    echo "4. Select $GIF_NAME and click 'Add'"
    echo "5. Make sure 'Copy items if needed' is checked"
    echo "6. Make sure 'LofiTimer' target is selected"
    echo "7. Build and run the app"
    echo ""
    echo "The GIF will automatically appear in the GIF Settings gallery!"
else
    echo "❌ Failed to copy the file"
    exit 1
fi