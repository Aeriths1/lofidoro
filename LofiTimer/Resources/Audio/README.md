# Audio Resources Structure

## Directory Structure

```
Audio/
├── music/           # Background music tracks
│   ├── nujabes/    # Nujabes style lofi hip-hop
│   ├── kudasai/    # Kudasai style chill beats
│   └── zelda/      # Zelda & gaming lofi remixes
└── effects/        # Sound effects
    ├── timer_start.mp3
    ├── timer_pause.mp3
    ├── timer_complete.mp3
    └── session_change.mp3
```

## Music Categories

### 🎵 Nujabes
Jazz-influenced hip-hop beats with soulful samples. Perfect for deep focus.
- Add files: `nujabes_track1.mp3`, `nujabes_track2.mp3`, etc.

### 🎸 Kudasai
Modern lofi with guitar elements and dreamy atmospheres.
- Add files: `kudasai_track1.mp3`, `kudasai_track2.mp3`, etc.

### 🎮 Zelda
Gaming-inspired lofi remixes, especially from Zelda series.
- Add files: `zelda_track1.mp3`, `zelda_track2.mp3`, etc.

## Adding Music

1. **File Naming**: Use descriptive names without spaces
   - Good: `nujabes-aruarian-dance.mp3`
   - Bad: `Track 1.mp3`

2. **File Format**: MP3 or M4A recommended
   - Bitrate: 128-320 kbps
   - Keep files under 10MB for smooth playback

3. **Adding to Xcode**:
   - Drag files to appropriate category folder
   - Select "Copy items if needed"
   - Add to target: "LofiTimer"

## Sound Effects

Default effects included:
- `timer_start.mp3` - Plays when timer starts
- `timer_pause.mp3` - Plays when timer pauses
- `timer_complete.mp3` - Plays when session completes
- `session_change.mp3` - Plays when switching between work/break

## Legal Note

Only add music you have the rights to use:
- Royalty-free music
- Creative Commons licensed tracks
- Music you've created
- Tracks with proper licensing

## Recommended Sources

- [Lofi Girl](https://lofigirl.com) - Official lofi music
- [Free Music Archive](https://freemusicarchive.org) - CC licensed music
- [YouTube Audio Library](https://www.youtube.com/audiolibrary) - Free music
- [Epidemic Sound](https://www.epidemicsound.com) - Subscription service
- [Artlist](https://artlist.io) - Subscription service