public class WebAppWindow : Gtk.ApplicationWindow {

    //widgets
    private WebApp web_app;
    private Gtk.HeaderBar headerbar;
    
    public WebAppWindow () {
        web_app = new WebApp(this);
        
        // set headerbar style
        headerbar = new Gtk.HeaderBar();
        headerbar.show_close_button = true;
        headerbar.title = "微信";
        set_titlebar (headerbar);
        
        // set windows size and position
        set_resizable(false);
        set_size_request ((int)(380 * 1.25), (int)(540 * 1.25));
        set_position(Gtk.WindowPosition.CENTER_ALWAYS);
        
        // quit when close
        this.delete_event.connect( () => {
            if (web_app.get_wx_state() == WebApp.WeiXinState.Main)
                return this.hide_on_delete();
            else
                Gtk.main_quit();
            return false;
        });
        
        add(web_app);
        show_all();
    }
}
