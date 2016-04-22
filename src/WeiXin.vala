static int main (string[] args) {

    Gtk.init (ref args);
    var app = new WebAppWindow();
    app.show_all();
    Gtk.main ();
    return 0;
}
