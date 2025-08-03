# Adding Custom GIFs

## How to Add Your Own GIFs

1. **Add GIF files to this folder**: Simply drag and drop your `.gif` files into this `Animations` folder in Xcode.

2. **Naming Convention**: 
   - Use descriptive names for your GIFs
   - Avoid spaces in filenames (use hyphens or underscores instead)
   - Examples: `lofi-girl.gif`, `study-cat.gif`, `cozy-room.gif`

3. **Recommended Specifications**:
   - **Resolution**: 1920x1080 or similar aspect ratio works best
   - **File Size**: Keep under 50MB for smooth performance
   - **Frame Rate**: 10-15 fps is usually sufficient
   - **Loop**: Make sure your GIFs loop seamlessly

4. **Xcode Setup**:
   - When adding GIFs to Xcode, make sure to:
     - Select "Copy items if needed"
     - Add to target: "LofiTimer"
     - The GIFs should appear in the app bundle

5. **Testing**:
   - After adding GIFs, rebuild the app
   - Open the GIF Settings (photo icon in the app)
   - Your new GIFs should appear automatically in the gallery

## Display Modes

Each GIF can be displayed in 4 different modes:

- **Fill Screen**: Fills the entire screen (may crop edges)
- **Fit to Screen**: Fits within screen boundaries (may show borders)
- **Stretch**: Stretches to fill (may distort the image)
- **Original Size**: Shows at original resolution with manual scale control

## Tips for Best Results

- For lofi/study aesthetic, choose GIFs with:
  - Warm, muted colors
  - Calm, repetitive animations
  - Cozy indoor scenes
  - Minimal movement to avoid distraction

- Test different display modes to find what works best for each GIF

## File Organization

You can organize GIFs in subfolders, but note that currently the app only scans the main Animations folder. All GIFs should be placed directly in this folder.

## Troubleshooting

If your GIFs don't appear:
1. Make sure the file extension is `.gif` (lowercase)
2. Check that the GIF is added to the LofiTimer target in Xcode
3. Clean and rebuild the project (Cmd+Shift+K, then Cmd+B)
4. Check the console for any error messages

## Popular Sources for Study GIFs

- [Giphy](https://giphy.com) - Search for "lofi", "study", "anime study"
- [Tenor](https://tenor.com) - Similar searches
- [Reddit r/PixelArt](https://reddit.com/r/PixelArt) - For pixel art GIFs
- Create your own using tools like After Effects, Procreate, or Aseprite