
<div align="center">
  <h1>LTUI</h1>

  <div>
    <a href="https://travis-ci.org/tboox/ltui">
      <img src="https://img.shields.io/travis/tboox/ltui/master.svg?style=flat-square" alt="travis-ci" />
    </a>
    <a href="https://ci.appveyor.com/project/waruqi/ltui/branch/master">
      <img src="https://img.shields.io/appveyor/ci/waruqi/ltui/master.svg?style=flat-square" alt="appveyor-ci" />
    </a>
    <a href="https://github.com/tboox/ltui/releases">
      <img src="https://img.shields.io/github/release/tboox/ltui.svg?style=flat-square" alt="Github All Releases" />
    </a>
    <a href="http://luarocks.org/modules/waruqi/ltui">
      <img src="https://img.shields.io/luarocks/v/waruqi/ltui.svg?style=flat-square" alt="Luarocks" />
    </a>
  </div>
  <div>
    <a href="https://github.com/tboox/ltui/blob/master/LICENSE.md">
      <img src="https://img.shields.io/github/license/tboox/ltui.svg?colorB=f48041&style=flat-square" alt="license" />
    </a>
    <a href="https://www.reddit.com/r/tboox/">
      <img src="https://img.shields.io/badge/chat-on%20reddit-ff3f34.svg?style=flat-square" alt="Reddit" />
    </a>
    <a href="https://gitter.im/tboox/tboox?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
      <img src="https://img.shields.io/gitter/room/tboox/tboox.svg?style=flat-square&colorB=96c312" alt="Gitter" />
    </a>
    <a href="https://t.me/tbooxorg">
      <img src="https://img.shields.io/badge/chat-on%20telegram-blue.svg?style=flat-square" alt="Telegram" />
    </a>
    <a href="https://jq.qq.com/?_wv=1027&k=5hpwWFv">
      <img src="https://img.shields.io/badge/chat-on%20QQ-ff69b4.svg?style=flat-square" alt="QQ" />
    </a>
    <a href="http://tboox.org/donation/">
      <img src="https://img.shields.io/badge/donate-us-orange.svg?style=flat-square" alt="Donate" />
    </a>
    </div>
  <p>A cross-platform terminal ui library based on Lua</p>
</div>

## 简介

LTUI是一个基于lua的跨平台字符终端UI界面库。 

此框架源于[xmake](https://github.com/tboox/xmake)中图形化菜单配置的需求，类似linux kernel的menuconf去配置编译参数，因此基于curses和lua实现了一整套跨平台的字符终端ui库。
而样式风格基本上完全参照的kconfig-frontends，当然用户也可以自己定制不同的ui风格。

<img src="https://tboox.org/static/img/ltui/choicebox.png" width="70%" />

## 安装

```console
$ luarocks install ltui
```

## 编译

我们需要先安装跨平台构建工具：[xmake](https://github.com/tboox/xmake)

```console
$ xmake
```

## 运行测试

你需要先安装[lua](https://www.lua.org/)或者[luajit](http://luajit.org/)程序去加载运行测试程序：

```console
$ xmake run test dialog
$ xmake run test window
$ xmake run test desktop
$ xmake run test inputdialog
$ xmake run test mconfdialog
```

或者

```console
$ lua tests\dialog.lua
$ lua tests\window.lua
$ lua tests\desktop.lua
$ lua tests\inputdialog.lua
$ lua tests\mconfdialog.lua
```

或者

```console
$ luajit tests\dialog.lua
$ luajit tests\window.lua
$ luajit tests\desktop.lua
$ luajit tests\inputdialog.lua
$ luajit tests\mconfdialog.lua
```

## 例子

#### 应用程序

```lua
local ltui        = require("ltui")
local application = ltui.application
local event       = ltui.event
local rect        = ltui.rect
local window      = ltui.window
local demo        = application()

function demo:init()
    application.init(self, "demo")
    self:background_set("blue")
    self:insert(window:new("window.main", rect {1, 1, self:width() - 1, self:height() - 1}, "main window", true))
end

demo:run()
```

#### 标签 

```lua
local lab = label:new("title", rect {0, 0, 12, 1}, "hello ltui!"):textattr_set("white")
```

#### 按钮 

```lua
local btn = button:new("yes", rect {0, 1, 7, 2}, "< Yes >"):textattr_set("white")
```

#### 输入框

```lua
function demo:init()
    -- ...

    local dialog_input = inputdialog:new("dialog.input", rect {0, 0, 50, 8})
    dialog_input:text():text_set("please input text:")
    dialog_input:button_add("no", "< No >", function (v) dialog_input:quit() end)
    dialog_input:button_add("yes", "< Yes >", function (v) dialog_input:quit() end)
    self:insert(dialog_input, {centerx = true, centery = true})
end
```

## 组件

| 视图      | 对话框       | 其他        |
| -------   | ------       | ------      |
| view      | dialog       | event       |
| panel     | boxdialog    | action      |
| label     | textdialog   | canvas      |
| button    | inputdialog  | curses      |
| border    | mconfdialog  | program     |
| window    | choicedialog | application |
| menubar   |              | point       |
| menuconf  |              | rect        |
| textedit  |              | object      |
| textarea  |              |             |
| statusbar |              |             |
| choicebox |              |             |
| desktop   |              |             |


## 快照

#### 菜单配置

<img src="https://tboox.org/static/img/ltui/menuconf.png" width="70%" />

#### 输入框

<img src="https://tboox.org/static/img/ltui/inputdialog.png" width="70%" />

#### 文本区域

<img src="https://tboox.org/static/img/ltui/textarea.png" width="70%" />


如果你想了解更多，请参考：

* [主页](https://tboox.org)
* [Github](https://github.com/tboox/ltui)
* [Gitee](https://gitee.com/tboox/ltui)

## 联系方式

* 邮箱：[waruqi@gmail.com](mailto:waruqi@gmail.com)
* 主页：[tboox.org](https://tboox.org)
* 社区：[Reddit论坛](https://www.reddit.com/r/tboox/)
* 聊天：[Telegram群组](https://t.me/tbooxorg), [Gitter聊天室](https://gitter.im/tboox/tboox?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
* 源码：[Github](https://github.com/tboox/ltui), [Gitee](https://gitee.com/tboox/ltui)
* QQ群：343118190
* 微信公众号：tboox-os

