class DropdownBrowserPlugin : Xfce.PanelPlugin {
    Settings settings;

    Gtk.ToggleButton button;
    Gtk.Image buttonIcon;
    Gtk.Label buttonLabel;

    Gtk.Window popup;
    WebKit.WebView webView;

    SettingsDialog settingsDialog;

    public override void @construct() {
        settings = Settings.load_from_file(this.lookup_rc_file());

        init_popup();
        init_button();

        menu_show_configure();

        configure_plugin.connect(show_configure);
        //save.connect(() => { settings.save_to_file(save_location(true)); });
        size_changed.connect(() => true);
        destroy.connect(() => { Gtk.main_quit (); });

        show_all();

        settings.for_each_property(setting_notify);
        settings.notify.connect(setting_notify);
    }

    void init_button() {
        button = (Gtk.ToggleButton)Xfce.panel_create_toggle_button();

        var hbox = new Gtk.HBox(false, 4);

        button.add(hbox);

        buttonIcon = new Gtk.Image();
        buttonIcon.set_alignment(0.5f, 0.5f);
        hbox.pack_start(buttonIcon, false, false, 0);

        buttonLabel = new Gtk.Label(null);
        hbox.pack_start(buttonLabel, false, false, 0);

        add(button);
        add_action_widget(button);

        button.toggled.connect(() => {
            if (button.active)
                show_popup();
            else
                popup.hide();
        });
    }

    void init_popup() {
        popup = new Gtk.Window();

        popup.title = "Drop-down browser";
        popup.decorated = false;
        popup.resizable = true;
        popup.skip_taskbar_hint = true;
        popup.skip_pager_hint = true;
        popup.set_size_request(settings.width, settings.height);
        popup.focus_out_event.connect(() => {
            popup.hide();
            button.active = false;
            return true;
        });

        var scroll = new Gtk.ScrolledWindow(null, null);
        scroll.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
        popup.add(scroll);

        webView = new WebKit.WebView();

        scroll.add(webView);
    }

    void setting_notify(ParamSpec p) {
        switch (p.name) {
            case "url":
                webView.open(settings.url);
                break;

            case "icon":
                {
                    Gdk.Pixbuf icon = settings.load_icon(button.get_screen(), 16);

                    buttonIcon.set_from_pixbuf(icon);
                }
                break;

            case "text":
                if (settings.text == null || settings.text == "") {
                    buttonLabel.hide();
                } else {
                    buttonLabel.label = settings.text;
                    buttonLabel.show();
                }
                break;

            case "width":
                popup.width_request = (settings.width <= 0) ? -1 : settings.width;
                break;

            case "height":
                popup.height_request = (settings.height <= 0) ? -1 : settings.height;
                break;
        }
    }

    void show_popup() {
        int btn_x, btn_y;
        button.get_window().get_origin(out btn_x, out btn_y);

        Gtk.Allocation btn_size;
        button.get_allocation(out btn_size);

        popup.show_all();

        Gdk.Rectangle screen_area;
        Gdk.Screen screen = button.get_screen();
        screen.get_monitor_geometry(screen.get_monitor_at_point(btn_x, btn_y), out screen_area);

        Gtk.Allocation popup_size;
        popup.get_allocation(out popup_size);

        int x, y;

        switch (screen_position) {
            case Xfce.ScreenPosition.NW_H:
            case Xfce.ScreenPosition.N:
            case Xfce.ScreenPosition.NE_H:
            case Xfce.ScreenPosition.FLOATING_H:
            default:

                // open below
                x = btn_x + (btn_size.width / 2) - (popup_size.width / 2);
                y = btn_y + btn_size.height;
                break;

            case Xfce.ScreenPosition.SW_H:
            case Xfce.ScreenPosition.S:
            case Xfce.ScreenPosition.SE_H:

                // open above
                x = btn_x + (btn_size.width / 2) - (popup_size.width / 2);
                y = btn_y - popup_size.height;
                break;

            case Xfce.ScreenPosition.NW_V:
            case Xfce.ScreenPosition.W:
            case Xfce.ScreenPosition.SW_V:
            case Xfce.ScreenPosition.FLOATING_V:

                // open to the right
                x = btn_x + btn_size.width;
                y = btn_y + (btn_size.height / 2) - (popup_size.height / 2);
                break;

            case Xfce.ScreenPosition.NE_V:
            case Xfce.ScreenPosition.E:
            case Xfce.ScreenPosition.SE_V:

                // open to the left
                x = btn_x - popup_size.width;
                y = btn_y + (btn_size.height / 2) - (popup_size.height / 2);
                break;
        }

        x = int.min(x, screen_area.x + screen_area.width - popup_size.width);
        x = int.max(x, screen_area.x);

        y = int.min(y, screen_area.y + screen_area.height - popup_size.height);
        y = int.max(y, screen_area.y);

        popup.move(x, y);
    }

    private void show_configure() {
        if (settingsDialog != null) {
            settingsDialog.present();
            return;
        }

        settingsDialog = new SettingsDialog();
        settingsDialog.destroy.connect(() => {
            settingsDialog = null;
            settings.save_to_file(save_location(true));
        });
        settingsDialog.show_settings(settings);
    }
}

[ModuleInit]
public Type xfce_panel_module_init(TypeModule module) {
    return typeof(DropdownBrowserPlugin);
}
