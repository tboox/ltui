---A cross-platform terminal ui library based on Lua
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
-- Copyright (C) 2015-2020, TBOOX Open Source Group.
--
-- @author      ruki
-- @file        textdialog.lua
--

-- load modules
local log       = require("ltui/base/log")
local rect      = require("ltui/rect")
local event     = require("ltui/event")
local dialog    = require("ltui/dialog")
local curses    = require("ltui/curses")
local textarea  = require("ltui/textarea")
local scrollbar = require("ltui/scrollbar")
local action    = require("ltui/action")

-- define module
local textdialog = textdialog or dialog()

-- init dialog
function textdialog:init(name, bounds, title)

    -- init window
    dialog.init(self, name, bounds, title)

    -- mark as scrollable, disabled by default
    self:option_set("scrollable", false)

    -- insert text
    self:panel():insert(self:text())

    -- insert scrollbar
    self:panel():insert(self:scrollbar())

    -- select buttons by default
    self:panel():select(self:buttons())

    -- on resize for panel
    self:panel():action_add(action.ac_on_resized, function (v)
        if self:option("scrollable") then
            self:text():bounds_set(rect:new(0, 0, v:width() - 1, v:height() - 1))
            self:scrollbar():bounds_set(rect:new(v:width() - 1, 0, 1, v:height() - 1))
        else
            self:text():bounds_set(rect:new(0, 0, v:width(), v:height() - 1))
        end
    end)

    -- on scroll for text and scrollbar
    self:text():action_set(action.ac_on_scrolled, function (v, progress)
        self:scrollbar():progress_set(progress)
    end)
end

-- enable or disable scrollbar
function textdialog:option_set(name, value)
    if name == "scrollable" then
        local oldvalue = self:option(name)
        if value ~= oldvalue then
            if value then
                self:text():bounds():resize(self:panel():width() - 1, self:panel():height() - 1)
                self:scrollbar():show(true)
            else
                self:text():bounds():resize(self:panel():width(), self:panel():height() - 1)
                self:scrollbar():show(false)
            end
            self:invalidate()
        end
    end
    dialog.option_set(self, name, value)
end

-- get text
function textdialog:text()
    if not self._TEXT then
        self._TEXT = textarea:new("textdialog.text", rect:new(0, 0, self:panel():width(), self:panel():height() - 1))
    end
    return self._TEXT
end

-- get scrollbar
function textdialog:scrollbar()
    if not self._SCROLLBAR then
        self._SCROLLBAR = scrollbar:new("textdialog.scrollbar", rect:new(self:panel():width() - 1, 0, 1, self:panel():height() - 1))
        self._SCROLLBAR:show(false)
    end
    return self._SCROLLBAR
end

-- on event
function textdialog:on_event(e)

    -- pass event to dialog
    if dialog.on_event(self, e) then
        return true
    end

    -- pass keyboard event to text area to scroll
    if e.type == event.ev_keyboard then
        return self:text():on_event(e)
    end
end

-- return module
return textdialog
