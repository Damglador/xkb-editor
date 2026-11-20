- Add preview
- UNDO
    - Renaming includes
- Toggle for labels on modifier keys
- Set file picker to only show text files
- Throw a different error if failed to open a file rather than parse
- Check if a file is a text file before trying to load it
- Confirm exit if the top object of undoStack doesn't match with one saved during last save operation
- Or check if toXkb() of current content matches to file's (easier)

# Long term

- Merging variants
- Generate evdev.xml for user-installed xkb layouts for them to appear in desktop settings
- Display actual modifiers for each level
    - Highlight the modifier keys when switched to the coresponding level
    - Figure out if layout modifier takes priority or global one
- Notify about inability to detect desktop-wide modifiers outside of KDE
- Handle alternative keycodes like LatA from ua(homophonic)
