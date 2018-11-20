<div align="center">
  <h1>LTUI</h1>

  <div>
    <a href="https://github.com/tboox/ltui/releases">
      <img src="https://img.shields.io/github/release/tboox/ltui.svg?style=flat-square" alt="Github All Releases" />
    </a>
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

## Introduction ([中文](/README_zh.md))

LTUI is a cross-platform terminal ui library based on Lua. 

This framework originated from the requirements of graphical menu configuration in [xmake](https://github.com/tboox/xmake). 
Similar to the kernel kernel's menuconf to configure the compilation parameters, so using curses and lua to implement a cross-platform character terminal ui library.

Refer to kconfig-frontends for style rendering. Of course, users can customize different ui styles.

<img src="https://tboox.org/static/img/ltui/choicebox.png" width="70%" />

## Build

We need install the cross-platform build utility [xmake](https://github.com/tboox/xmake) first.

```console
$ xmake
```

## Examples

#### Application

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

#### Label 

```lua
local lab = label:new("title", rect {0, 0, 12, 1}, "hello ltui!"):textattr_set("white")
```

#### Button 

```lua
local btn = button:new("yes", rect {0, 1, 7, 2}, "< Yes >"):textattr_set("white")
```

#### Input dialog

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

## Components

| views |
|------- |
| view |
| panel |
| label |
| button |
| border |
| window |
| menubar |
| menuconf |
| textedit |
| textarea |
| statusbar |
| choicebox |
| desktop |


| dialogs |
|------- |
| dialog |
| boxdialog |
| textdialog |
| inputdialog |
| mconfdialog |
| choicedialog |


## Snapshot

#### Menu configuation

<img src="https://tboox.org/static/img/ltui/menuconf.png" width="70%" />

#### Input dialog

<img src="https://tboox.org/static/img/ltui/inputdialog.png" width="70%" />

#### Text area

<img src="https://tboox.org/static/img/ltui/textarea.png" width="70%" />

## Run tests

```console
$ luajit tests\dialog.lua
$ luajit tests\window.lua
$ luajit tests\desktop.lua
$ luajit tests\inputdialog.lua
$ luajit tests\mconfdialog.lua
```

If you want to known more, please refer to:

* [HomePage](https://tboox.org)
* [Github](https://github.com/tboox/ltui)
* [Gitee](https://gitee.com/tboox/ltui)

## Contacts

* Email：[waruqi@gmail.com](mailto:waruqi@gmail.com)
* Homepage：[tboox.org](https://tboox.org)
* Community：[/r/tboox on reddit](https://www.reddit.com/r/tboox/)
* ChatRoom：[Char on telegram](https://t.me/tbooxorg), [Chat on gitter](https://gitter.im/tboox/tboox?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
* Source Code：[Github](https://github.com/tboox/ltui), [Gitee](https://gitee.com/tboox/ltui)

