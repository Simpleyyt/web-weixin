# Web 版微信应用

elementaryOS 或 Ubuntu 上的 Web 版微信应用。

![](screenshot/screenshot1.png)

## 功能

 * 完整的 Web 微信功能
 * 独立的窗口扫码界面
 * 支持 AppIndication 并有蓝点提示消息功能。
 * 支持 libnotify 消息提醒。

## 截图

![](screenshot/screenshot2.png)
![](screenshot/screenshot3.png)
![](screenshot/screenshot4.png)

## 依赖

 * gobject-2.0
 * glib-2.0
 * gio-2.0
 * gtk+-3.0>=3.12
 * webkit2gtk-4.0
 * appindicator3-0.1

## 编译

```sh
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
make
sudo make install
```

## Bugs

 * 有时候需要退2次才能退出程序。

