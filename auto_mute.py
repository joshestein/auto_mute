#!/usr/bin/env python3

import os
import signal
import subprocess
import gi
gi.require_version('AppIndicator3', '0.1')
gi.require_version('Gtk', '3.0')
from gi.repository import AppIndicator3, Gtk


APP_ID = 'auto_mute_controller'
SCRIPT = './auto_mute.sh'

class TrayIcon():
    def __init__(self):
        self.active = None
        self.pid = None
        # path = os.path.dirname(os.path.abspath(__file__))
        self.indicator = AppIndicator3.Indicator.new(
                APP_ID,
                os.path.abspath("off.png"),
                AppIndicator3.IndicatorCategory.SYSTEM_SERVICES)
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self.build_menu())
        self.enable_auto_mute()

    def build_menu(self):
        menu = Gtk.Menu()

        if self.active:
            menu_toggle = Gtk.MenuItem(label='Disable')
            menu_toggle.connect('activate', self.kill_auto_mute)
        else:
            menu_toggle = Gtk.MenuItem(label='Enable')
            menu_toggle.connect('activate', self.enable_auto_mute)

        item_quit = Gtk.MenuItem(label='Quit')
        item_quit.connect('activate', self.quit)

        menu.append(menu_toggle)
        menu.append(item_quit)
        menu.show_all()
        return menu

    def enable_auto_mute(self, source=None):
        self.pid = subprocess.Popen([SCRIPT], preexec_fn=os.setsid)
        self.active = True
        self.indicator.set_icon_full(os.path.abspath("off.png"), "off")
        self.indicator.set_menu(self.build_menu())

    def kill_auto_mute(self, source):
        os.killpg(os.getpgid(self.pid.pid), signal.SIGTERM)
        self.active = False
        self.indicator.set_icon_full(os.path.abspath("on.png"), "on")
        self.indicator.set_menu(self.build_menu())

    def quit(self, source):
        if self.pid:
            os.killpg(os.getpgid(self.pid.pid), signal.SIGTERM)
        Gtk.main_quit()


if __name__ == '__main__':
    tray = TrayIcon()
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    Gtk.main()
