class SettingsDialog : Xfce.TitledDialog {
    Settings settings;

    Gtk.Entry url = new Gtk.Entry();
    new Gtk.Button icon = new Gtk.Button();
    Gtk.Entry text = new Gtk.Entry();
    Gtk.SpinButton width = new Gtk.SpinButton.with_range(0, 9999, 1);
    Gtk.SpinButton height = new Gtk.SpinButton.with_range(0, 9999, 1);

    public SettingsDialog() {
        title = "Drop-down browser";
        icon_name = "gtk-properties";

        add_buttons(
            dgettext("gtk30", "_Close"), Gtk.ResponseType.CLOSE,
            null);

        Gtk.Grid grid = new Gtk.Grid();
        grid.margin = 16;

        grid.row_spacing = 16;
        grid.column_spacing = 16;

        grid.attach(label("_URL:", url), 0, 0, 1, 1);
        grid.attach(url, 1, 0, 1, 1);
        url.set_hexpand(true);

        grid.attach(label("_Icon:", icon), 0, 1, 1, 1);
        Gtk.Box iconBox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        iconBox.add(icon);
        grid.attach(iconBox, 1, 1, 1, 1);

        grid.attach(label("_Text:", text), 0, 2, 1, 1);
        grid.attach(text, 1, 2, 1, 1);

        grid.attach(label("_Width:", width), 0, 3, 1, 1);
        grid.attach(width, 1, 3, 1, 1);

        grid.attach(label("_Height:", height), 0, 4, 1, 1);
        grid.attach(height, 1, 4, 1, 1);

        get_content_area().add(grid);

        response.connect((t, r) => {
            if (r == Gtk.ResponseType.CLOSE)
                destroy();
        });

        url.focus_out_event.connect(() => { settings.url = url.text; return false; });

        icon.clicked.connect(icon_clicked);

        text.focus_out_event.connect(() => { settings.text = text.text; return false; });

        width.focus_out_event.connect(() => { settings.width = (int)width.value; return false; });

        height.focus_out_event.connect(() => { settings.height = (int)height.value; return false; });
    }

    public void show_settings(Settings settings) {
        this.settings = settings;

        show_all();

        url.text = settings.url;
        set_icon_value(icon, settings.load_icon(screen, 48));
        text.text = settings.text;
        width.value = settings.width;
        height.value = settings.height;
    }

    void icon_clicked() {
        var dlg = new Exo.IconChooserDialog("Select an icon", this);
        dlg.add_buttons(
            dgettext("gtk30", "_Cancel"), Gtk.ResponseType.CANCEL,
            dgettext("gtk30", "_Ok"), Gtk.ResponseType.OK,
            null);

        dlg.response.connect((t, r) => {
            if (r == Gtk.ResponseType.OK) {
                settings.icon = dlg.get_icon();

                set_icon_value(icon, settings.load_icon(screen, 48));
            }

            dlg.destroy();
        });

        dlg.set_icon(settings.icon);

        dlg.run();
    }

    static Gtk.Label label(string text, Gtk.Widget widget) {
        Gtk.Label lbl = new Gtk.Label.with_mnemonic(text);
        lbl.mnemonic_widget = widget;
        return lbl;
    }

    static void set_icon_value(Gtk.Button btn, Gdk.Pixbuf? value) {
        if (value == null)
            btn.set_label("No icon");
        else
            btn.set_image(new Gtk.Image.from_pixbuf(value));
    }
}
