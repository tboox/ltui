package = "ltui"
version = "1.0-1"
source = {
    url = "https://github.com/tboox/ltui.git",
    tag = "v1.0"
}
description = {
    detailed = [[
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
        </div>]],
    homepage = "https://tboox.org",
    summary = "A cross-platform terminal ui library based on Lua",
    license = "Apache-2.0"
}
dependencies = {
    "lua >= 5.1"
}
build = {
    type = "builtin",
    modules = {
        ["ltui"] = {
            sources = "src/core/lcurses/lcurses.c"
        }
    },
    install = {
        lua = {
            ["ltui"] = "src/ltui.lua",
            ["ltui.action"] = "src/ltui/action.lua",
            ["ltui.application"] = "src/ltui/application.lua",
            ["ltui.base.dlist"] = "src/ltui/base/dlist.lua",
            ["ltui.base.log"] = "src/ltui/base/log.lua",
            ["ltui.base.os"] = "src/ltui/base/os.lua",
            ["ltui.base.path"] = "src/ltui/base/path.lua",
            ["ltui.base.string"] = "src/ltui/base/string.lua",
            ["ltui.base.table"] = "src/ltui/base/table.lua",
            ["ltui.border"] = "src/ltui/border.lua",
            ["ltui.boxdialog"] = "src/ltui/boxdialog.lua",
            ["ltui.button"] = "src/ltui/button.lua",
            ["ltui.canvas"] = "src/ltui/canvas.lua",
            ["ltui.choicebox"] = "src/ltui/choicebox.lua",
            ["ltui.choicedialog"] = "src/ltui/choicedialog.lua",
            ["ltui.curses"] = "src/ltui/curses.lua",
            ["ltui.desktop"] = "src/ltui/desktop.lua",
            ["ltui.dialog"] = "src/ltui/dialog.lua",
            ["ltui.event"] = "src/ltui/event.lua",
            ["ltui.inputdialog"] = "src/ltui/inputdialog.lua",
            ["ltui.label"] = "src/ltui/label.lua",
            ["ltui.mconfdialog"] = "src/ltui/mconfdialog.lua",
            ["ltui.menubar"] = "src/ltui/menubar.lua",
            ["ltui.menuconf"] = "src/ltui/menuconf.lua",
            ["ltui.object"] = "src/ltui/object.lua",
            ["ltui.panel"] = "src/ltui/panel.lua",
            ["ltui.point"] = "src/ltui/point.lua",
            ["ltui.program"] = "src/ltui/program.lua",
            ["ltui.rect"] = "src/ltui/rect.lua",
            ["ltui.statusbar"] = "src/ltui/statusbar.lua",
            ["ltui.textarea"] = "src/ltui/textarea.lua",
            ["ltui.textdialog"] = "src/ltui/textdialog.lua",
            ["ltui.textedit"] = "src/ltui/textedit.lua",
            ["ltui.view"] = "src/ltui/view.lua",
            ["ltui.window"] = "src/ltui/window.lua"
        }
    },
    copy_directories = {
        "tests"
    }
}
