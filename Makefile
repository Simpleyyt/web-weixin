weixin: *.vala
	valac --pkg webkit2gtk-4.0 --pkg gtk+-3.0 *.vala --pkg libnotify --pkg appindicator3-0.1 -o WeiXin
