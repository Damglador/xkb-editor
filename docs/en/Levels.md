# General

Each variant has up to a certain amount of levels and each key has a symbol for each level.

You can switch levels by using modifier keys, like Shift, RAlt, etc. By default only two levels are available — the default one and the second one, the Shift level. But you can have a [variant] with up to 8 levels.

# Level 3 & 4

You can add up to 4 symbols per key without any special configuration. But by default you will not have a modifier to switch to levels 3 and 4. You can add one by either including `level3` in your variant, which, by default, will assign RAlt to switch to level 3 or by choosing a global modifier for level 3 in Plasma settings under `Keyboard > Keyboard > Key Bindings > Key to choose the 3rd level`

# Level 5–8

Levels above 4 require you to specify `key.type = "EIGHT_LEVEL"`, which can be done per-key:

```c
partial alphanumeric_keys
xkb_symbols "custom" {
    name[Group1] = "English (Custom)";

    key <AE01> { [ "1", "2", "3", "4", "5" ], type="EIGHT_LEVEL" }; //<--
};
```

or for a whole variant:

```c
partial alphanumeric_keys
xkb_symbols "custom" {
    name[Group1] = "English (Custom)";

    key <AE01> { [ "1", "2", "3", "4", "5" ] };

    key.type = "EIGHT_LEVEL"; // <--
};
```

Then it's the same as with [Level 3 & 4], you can include level5 (which uses RCtrl by default) for a modifier or configure it in Plasma settings.

# Modifiers

Default modifiers for each level:

| Level | Modifier             |
| ----- | -------------------- |
| 1     | N/A                  |
| 2     | Shift                |
| 3     | RAlt                 |
| 4     | RAlt + Shift         |
| 5     | RCtrl                |
| 6     | RCtrl + Shift        |
| 7     | RCtrl + RAlt         |
| 8     | RCtrl + RAlt + Shift |

If you configure a different modifier for level 3, then imagine the table has your modifier instead of RAlt, same for level 5 and RCtrl.
