class Settings : Object {
    public delegate void PropertyIterator(ParamSpec name);

    public const int MIN_WIDTH = 10;
    public const int MIN_HEIGHT = 10;

    public string url { get; set; default = ""; }

    public string icon { get; set; default = "emblem-web"; }
    public string text { get; set; default = ""; }

    public int width { get; set; default = 640; }
    public int height { get; set; default = 320; }

    public Gdk.Pixbuf? load_icon(Gdk.Screen screen, int size) {
        try {
            return Xfce.panel_pixbuf_from_source(icon, Gtk.IconTheme.get_for_screen(screen), size);
        } catch {
            error("Failed to load icon");
            Gtk.main_quit();
            return null;
        }
    }

    public void for_each_property(PropertyIterator iter) {
        foreach (ParamSpec spec in get_class().list_properties())
            iter(spec);
    }

    const string G = "Settings";

    public static Settings load_from_file(string? file) {
        try {
            var s = new Settings();
            if (file == null)
                return s;

            var f = new KeyFile();
            f.load_from_file(file, KeyFileFlags.NONE);

            s.url = f.get_string(G, "URL");

            s.icon = f.get_string(G, "Icon");
            s.text = f.get_string(G, "Text");

            s.width = int.max(0, f.get_integer(G, "Width"));
            s.height = int.max(0, f.get_integer(G, "Height"));

            return s;
        } catch {
            return new Settings();
        }
    }

    public void save_to_file(string file) {
        var f = new KeyFile();

        f.set_string(G, "URL", url);

        f.set_string(G, "Icon", icon);
        f.set_string(G, "Text", text);

        f.set_integer(G, "Width", width);
        f.set_integer(G, "Height", height);

        try {
            GLib.FileUtils.set_contents(file, f.to_data());
        } catch (GLib.FileError e) {
            error("dropdownbrowser: Couldn't save settings");
        }
    }
}

