from PySide6.QtCore import QObject


class Text(QObject):
    def __init__(self):
        super().__init__(None, objectName="Level modifier")
        self.ralt  = self.tr("Right Alt")
        self.lalt  = self.tr("Left Alt")
        self.alt   = self.tr("Any Alt")
        self.rctrl = self.tr("Right Ctrl")
        self.lsgt  = self.tr("Less/Greater key")
        self.rwin  = self.tr("Right Meta")
        self.lwin  = self.tr("Left Meta")
        self.win   = self.tr("Meta")
        self.switches = {
            "ralt_switch": self.ralt,
            "ralt_alt": f"Not {self.ralt}",
            "ralt_switch_multikey": self.ralt,
            "alt_switch": self.alt,
            "lalt_switch": self.lalt,
            "switch": self.rctrl,
            "menu_switch": "Menu",
            "win_switch": self.win,
            "lwin_switch": self.lwin,
            "rwin_switch": self.rwin,
            "enter_switch": "Keypad Enter",
            "caps_switch": "Caps Lock",
            "caps_switch_capslock_with_ctrl": "Caps Lock",
            "bksl_switch": "Backslash",
            "ac11_switch": "AC11",  # <--- this one should use something better
            "lsgt_switch": self.lsgt,
            "caps_switch_latch": "Caps Lock(Latch)",
            "bksl_switch_latch": "Backslash(Latch)",
            "lsgt_switch_latch": f"{self.lsgt}(Latch)",
            "4_switch_isolated": "AE04",
            "9_switch_isolated": "AE09",
            # Level 5
            "rctrl_switch": self.rctrl,
            "lsgt_switch_lock": f"{self.lsgt}(Lock)",
            "lwin_switch_lock": f"{self.lwin}(Lock)",
            "ralt_switch_lock": f"{self.ralt}(Lock)",
            "rwin_switch_lock": f"{self.rwin}(Lock)",
            "lsgt_switch_lock_cancel": "",
            "lwin_switch_lock_cancel": "",
            "ralt_switch_lock_cancel": "",
            "rwin_switch_lock_cancel": "",
        }
