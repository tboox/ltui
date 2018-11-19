
--!A cross-platform terminal ui library based on Lua
--
-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
-- 
-- Copyright (C) 2015 - 2018, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        ltui.lua
--

-- define module
local ltui = ltui or {}

-- register modules
ltui.action       = require("ltui/action")
ltui.application  = require("ltui/application")
ltui.border       = require("ltui/border")
ltui.boxdialog    = require("ltui/boxdialog")
ltui.button       = require("ltui/button")
ltui.canvas       = require("ltui/canvas")
ltui.choicebox    = require("ltui/choicebox")
ltui.choicedialog = require("ltui/choicedialog")
ltui.curses       = require("ltui/curses")
ltui.desktop      = require("ltui/desktop")
ltui.dialog       = require("ltui/dialog")
ltui.event        = require("ltui/event")
ltui.inputdialog  = require("ltui/inputdialog")
ltui.label        = require("ltui/label")
ltui.mconfdialog  = require("ltui/mconfdialog")
ltui.menubar      = require("ltui/menubar")
ltui.menuconf     = require("ltui/menuconf")
ltui.object       = require("ltui/object")
ltui.panel        = require("ltui/panel")
ltui.point        = require("ltui/point")
ltui.program      = require("ltui/program")
ltui.rect         = require("ltui/rect")
ltui.statusbar    = require("ltui/statusbar")
ltui.textarea     = require("ltui/textarea")
ltui.textdialog   = require("ltui/textdialog")
ltui.textedit     = require("ltui/textedit")
ltui.view         = require("ltui/view")
ltui.window       = require("ltui/window")

-- return module
return ltui
