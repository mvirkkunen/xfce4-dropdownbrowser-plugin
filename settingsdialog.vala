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
            Gtk.Stock.CLOSE, Gtk.ResponseType.CLOSE,
            null);

        Gtk.Table table = new Gtk.Table(5, 2, false);

        table.row_spacing = 8;
        table.column_spacing = 8;

        table.attach_defaults(label("_URL:", url), 0, 1, 0, 1);
        table.attach_defaults(url, 1, 2, 0, 1);

        table.attach_defaults(label("_Icon:", icon), 0, 1, 1, 2);
        table.attach(icon, 1, 2, 1, 2, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.SHRINK, 0, 0);
        //table.attach_defaults(icon, 1, 2, 1, 2);

        table.attach_defaults(label("_Text:", text), 0, 1, 2, 3);
        table.attach_defaults(text, 1, 2, 2, 3);

        table.attach_defaults(label("_Width:", width), 0, 1, 3, 4);
        table.attach(width, 1, 2, 3, 4, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.SHRINK, 0, 0);

        table.attach_defaults(label("_Height:", height), 0, 1, 4, 5);
        table.attach(height, 1, 2, 4, 5, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.SHRINK, 0, 0);

        ((Gtk.VBox)get_content_area()).add(table);

        response.connect((t, r) => {
            if (r == Gtk.ResponseType.CLOSE)
                destroy();
        });

        url.focus_out_event.connect(() => { settings.url = url.text; return false; });

        icon.set_alignment(0.0f, 0.5f);
        icon.clicked.connect(icon_clicked);

        text.focus_out_event.connect(() => { settings.text = text.text; return false; });

        width.set_alignment(0.0f);
        width.focus_out_event.connect(() => { settings.width = (int)width.value; return false; });

        height.set_alignment(0.0f);
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
            Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
            Gtk.Stock.OK, Gtk.ResponseType.OK,
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
        lbl.set_alignment(1.0f, 0.5f);
        lbl.set_alignment(1.0f, 0.5f);

        return lbl;
    }

    static void set_icon_value(Gtk.Button btn, Gdk.Pixbuf? value) {
        if (value == null)
            btn.set_label("No icon");
        else
            btn.set_image(new Gtk.Image.from_pixbuf(value));
    }
}
