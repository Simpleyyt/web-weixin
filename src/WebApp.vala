using AppIndicator;

public class WebApp : Gtk.Stack {

    public WebKit.WebView app_view;
    private Gtk.Box container; //the spinner container
    private Indicator indicator;
    private Gtk.Window window;
    private bool is_script_run = false;
    
    public enum WeiXinState {
        Login, Main
    }
    
    private WeiXinState state = WeiXinState.Login;
    
    public WebApp(WebAppWindow window) {
        this.window = window;
        
        //load app viewer
        app_view = new  WebKit.WebView.with_context (WebKit.WebContext.get_default ());
        app_view.load_uri ("https://wx.qq.com");
        
        //loading view
        var spinner = new Gtk.Spinner();
        spinner.active = true;
        spinner.halign = Gtk.Align.CENTER;
        spinner.valign = Gtk.Align.CENTER;
        spinner.set_size_request (24, 24);
        container = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
        container.halign = Gtk.Align.FILL;
        container.valign = Gtk.Align.FILL;
        container.pack_start(spinner, true, true, 0);
        
        
        
        //overlay trick to make snapshot work even with the spinner
        var overlay = new Gtk.Overlay ();
        overlay.add(app_view);
        overlay.add_overlay(container);
        add_titled(overlay, "app", "app");
        set_visible_child_name ("app");
        
        
        // show indicator
        indicator = new Indicator("微信", "indicator-weixin", IndicatorCategory.APPLICATION_STATUS);
        indicator.set_status(IndicatorStatus.ACTIVE);
        
        indicator.set_attention_icon("indicator-weixin-new");
        
        // add menu to indicator
        var menu = new Gtk.Menu();
        
        // show weixin menu item
        var item = new Gtk.MenuItem.with_label("显示微信");
        item.activate.connect(() => {
            // show window
            window.present();
            
            // show above
            window.set_keep_above(true);
            window.set_keep_above(false);
        });
        item.show();
        menu.append(item);
        
        // exit weixin menu item
        item = new Gtk.MenuItem.with_label("退出微信");
        item.show();
        item.activate.connect(() => {
            // quit window
            Gtk.main_quit();
        });
        menu.append(item);
        indicator.set_menu(menu);
        
        app_view.show_notification.connect( (notification) => {
            indicator.set_status(IndicatorStatus.ATTENTION);
            return false;
        });
        
        
        window.focus_in_event.connect( (directrion) => {
            indicator.set_status(IndicatorStatus.ACTIVE);
            return false;
        });
        
        app_view.load_changed.connect ( (load_event) => {
            // dispatch event to handler
            switch (app_view.uri) {
            case "https://wx.qq.com/":
                state = WeiXinState.Login;
                handleLoginPage(load_event);
                break;
            case "https://wx2.qq.com/":
                state = WeiXinState.Main;
                handleMainPage(load_event);
                break;
            }
        });
        
        
        app_view.permission_request.connect( (permission_request) => {
            // allow all permission request
            permission_request.allow();
            return false;
        });
    }
    public WeiXinState get_wx_state() {
        return state;
    }
    
    async void run_script() {
        
        // run until success
        if (is_script_run)
            return;
        try {
            yield app_view.run_javascript("window.scrollTo(240, 80);" +
                "document.body.style.overflow = 'hidden';", null);
            is_script_run = true;
        } catch (Error e) {
            is_script_run = false;
        }
        
    }
    
    void handleLoginPage(WebKit.LoadEvent load_event) {
        if (load_event == WebKit.LoadEvent.COMMITTED) {
            Timeout.add_seconds(1, () => {
                if (is_script_run) {
                    container.set_visible(false);
                    return false;
                }
                run_script();
                return true;
            });
        }
    }
    
    void handleMainPage(WebKit.LoadEvent load_event) {
        if (load_event == WebKit.LoadEvent.COMMITTED) {
            container.set_visible(false);
            window.set_size_request((int)(800 * 1.25), (int)(600 * 1.25));
        }
    }
}
