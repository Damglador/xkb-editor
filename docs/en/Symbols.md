# General

You can specify one symbol per key, a symbol can be specified as a character, like `Ї`, a "keycode" (xkb's code name for a symbol), like `Ukrainian_yi`, or as a unicode code point, like `U0457`. Note that unicode code point shouldn't have a plus, like `U+0457`, if you input it with the plus, the editor will automatically remove it before writing the symbol change.

# Dead symbols

Some symbols are "dead", a dead symbol inputs nothing on its own and modifies the next character you type. For example pressing `dead_abovering` and `a` will type `å` instead of `a`.

Dead symbols will be red on the preview and keys with dead symbols will be marked with a 💀 in the editor mode.
