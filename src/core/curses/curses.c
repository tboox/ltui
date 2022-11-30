/*!A cross-platform terminal ui library based on Lua
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Copyright (C) 2016-present, TBOOX Open Source Group.
 *
 * @author      ruki
 * @file        curses.c
 *
 */

/* //////////////////////////////////////////////////////////////////////////////////////
 * includes
 */
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#ifndef LUAJIT
#   define LUA_COMPAT_5_1
#   define LUA_COMPAT_5_3
#   define LUA_COMPAT_ALL
#endif
#include "luaconf.h"
#undef LUA_API
#if defined(__cplusplus)
#   define LUA_API extern "C"
#else
#   define LUA_API extern
#endif

#ifdef LUAJIT
#   include "luajit.h"
#else
#   include "lua.h"
#endif
#include "lualib.h"
#include "lauxlib.h"

#include <curses.h>

#if defined(NCURSES_VERSION)
#   include <locale.h>
#endif

/* //////////////////////////////////////////////////////////////////////////////////////
 * macros
 */

#define LT_CURSES_STDSCR   "curses.stdscr"
#define LT_CURSES_WINDOW   "curses.window"
#define LT_CURSES_OK(v)    (((v) == ERR) ? 0 : 1)

// define functions
#define LT_CURSES_NUMBER(n) \
    static int lt_curses_ ## n(lua_State* lua) \
    { \
        lua_pushnumber(lua, n()); \
        return 1; \
    }

#define LT_CURSES_NUMBER2(n, v) \
    static int lt_curses_ ## n(lua_State* lua) \
    { \
        lua_pushnumber(lua, v); \
        return 1; \
    }

#define LT_CURSES_BOOL(n) \
    static int lt_curses_ ## n(lua_State* lua) \
    { \
        lua_pushboolean(lua, n()); \
        return 1; \
    }

#define LT_CURSES_BOOLOK(n) \
    static int lt_curses_ ## n(lua_State* lua) \
    { \
        lua_pushboolean(lua, LT_CURSES_OK(n())); \
        return 1; \
    }

#define LT_CURSES_WINDOW_BOOLOK(n) \
    static int lt_curses_window_ ## n(lua_State* lua) \
    { \
        WINDOW* w = lt_curses_window_check(lua, 1); \
        lua_pushboolean(lua, LT_CURSES_OK(n(w))); \
        return 1; \
    }

// define constants
#define LT_CURSES_CONST_(n, v) \
    lua_pushstring(lua, n); \
    lua_pushnumber(lua, v); \
    lua_settable(lua, lua_upvalueindex(1));

#define LT_CURSES_CONST(s)       LT_CURSES_CONST_(#s, s)
#define LT_CURSES_CONST2(s, v)   LT_CURSES_CONST_(#s, v)

// export
#if defined(_WIN32)
#   define __export         __declspec(dllexport)
#elif defined(__GNUC__) && ((__GNUC__ >= 4) || (__GNUC__ == 3 && __GNUC_MINOR__ >= 3))
#   define __export         __attribute__((visibility("default")))
#else
#   define __export
#endif

/* //////////////////////////////////////////////////////////////////////////////////////
 * globals
 */

// map key for pdcurses, keeping the keys consistent with ncurses
static int g_mapkey = 0;

/* //////////////////////////////////////////////////////////////////////////////////////
 * private implementation
 */
static chtype lt_curses_checkch(lua_State* lua, int index)
{
    if (lua_type(lua, index) == LUA_TNUMBER)
        return (chtype)luaL_checknumber(lua, index);
    if (lua_type(lua, index) == LUA_TSTRING)
        return *lua_tostring(lua, index);
#ifdef LUAJIT
    luaL_typerror(lua, index, "chtype");
#endif
    return (chtype)0;
}

// get character and map key
static int lt_curses_window_getch_impl(WINDOW* w)
{
#ifdef PDCURSES
    static int has_key = 0;
    static int temp_key = 0;

    int key;
    if (g_mapkey && has_key)
    {
        has_key = 0;
        return temp_key;
    }

    key = wgetch(w);
    if (key == ERR || !g_mapkey) return key;
    if (key >= ALT_A && key <= ALT_Z)
    {
        has_key = 1;
        temp_key = key - ALT_A + 'A';
    }
    else if (key >= ALT_0 && key <= ALT_9)
    {
        has_key = 1;
        temp_key = key - ALT_0 + '0';
    }
    else
    {
        switch (key)
        {
            case ALT_DEL:       temp_key = KEY_DC;      break;
            case ALT_INS:       temp_key = KEY_IC;      break;
            case ALT_HOME:      temp_key = KEY_HOME;    break;
            case ALT_END:       temp_key = KEY_END;     break;
            case ALT_PGUP:      temp_key = KEY_PPAGE;   break;
            case ALT_PGDN:      temp_key = KEY_NPAGE;   break;
            case ALT_UP:        temp_key = KEY_UP;      break;
            case ALT_DOWN:      temp_key = KEY_DOWN;    break;
            case ALT_RIGHT:     temp_key = KEY_RIGHT;   break;
            case ALT_LEFT:      temp_key = KEY_LEFT;    break;
            case ALT_BKSP:      temp_key = KEY_BACKSPACE; break;
            default: return key;
        }
    }
    has_key = 1;
    return 27;
#else
    return wgetch(w);
#endif
}

// new a window object
static void lt_curses_window_new(lua_State* lua, WINDOW* nw)
{
    if (nw)
    {
        WINDOW** w = (WINDOW**)lua_newuserdata(lua, sizeof(WINDOW*));
        luaL_getmetatable(lua, LT_CURSES_WINDOW);
        lua_setmetatable(lua, -2);
        *w = nw;
    }
    else
    {
        lua_pushliteral(lua, "failed to create window");
        lua_error(lua);
    }
}

// get window
static WINDOW** lt_curses_window_get(lua_State* lua, int index)
{
    WINDOW** w = (WINDOW**)luaL_checkudata(lua, index, LT_CURSES_WINDOW);
    if (w == NULL) luaL_argerror(lua, index, "bad curses window");
    return w;
}

// get and check window
static WINDOW* lt_curses_window_check(lua_State* lua, int index)
{
    WINDOW** w = lt_curses_window_get(lua, index);
    if (*w == NULL) luaL_argerror(lua, index, "attempt to use closed curses window");
    return *w;
}

// tostring(window)
static int lt_curses_window_tostring(lua_State* lua)
{
    WINDOW** w = lt_curses_window_get(lua, 1);
    char const* s = NULL;
    if (*w) s = (char const*)lua_touserdata(lua, 1);
    lua_pushfstring(lua, "curses window (%s)", s? s : "closed");
    return 1;
}

// window:move(y, x)
static int lt_curses_window_move(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int y = luaL_checkint(lua, 2);
    int x = luaL_checkint(lua, 3);
    lua_pushboolean(lua, LT_CURSES_OK(wmove(w, y, x)));
    return 1;
}

// window:getyx(y, x)
static int lt_curses_window_getyx(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int y, x;
    getyx(w, y, x);
    lua_pushnumber(lua, y);
    lua_pushnumber(lua, x);
    return 2;
}

// window:getmaxyx(y, x)
static int lt_curses_window_getmaxyx(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int y, x;
    getmaxyx(w, y, x);
    lua_pushnumber(lua, y);
    lua_pushnumber(lua, x);
    return 2;
}

// window:delwin()
static int lt_curses_window_delwin(lua_State* lua)
{
    WINDOW** w = lt_curses_window_get(lua, 1);
    if (*w && *w != stdscr)
    {
        delwin(*w);
        *w = NULL;
    }
    return 0;
}

// window:addch(ch)
static int lt_curses_window_addch(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    chtype ch = lt_curses_checkch(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(waddch(w, ch)));
    return 1;
}

// window:addnstr(str)
static int lt_curses_window_addnstr(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    const char* str = luaL_checkstring(lua, 2);
    int n = luaL_optint(lua, 3, -1);
    if (n < 0) n = (int)lua_strlen(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(waddnstr(w, str, n)));
    return 1;
}

// window:keypad(true)
static int lt_curses_window_keypad(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int enabled = lua_isnoneornil(lua, 2) ? 1 : lua_toboolean(lua, 2);
    if (enabled)
    {
        // on WIN32 ALT keys need to be mapped, so to make sure you get the wanted keys,
        // only makes sense when using keypad(true) and echo(false)
        g_mapkey = 1;
    }
    lua_pushboolean(lua, LT_CURSES_OK(keypad(w, enabled)));
    return 1;
}

// window:meta(true)
static int lt_curses_window_meta(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int enabled = lua_toboolean(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(meta(w, enabled)));
    return 1;
}

// window:nodelay(true)
static int lt_curses_window_nodelay(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int enabled = lua_toboolean(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(nodelay(w, enabled)));
    return 1;
}

// window:leaveok(true)
static int lt_curses_window_leaveok(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int enabled = lua_toboolean(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(leaveok(w, enabled)));
    return 1;
}

// window:getch()
static int lt_curses_window_getch(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int c = lt_curses_window_getch_impl(w);
    if (c == ERR) return 0;
    lua_pushnumber(lua, c);
    return 1;
}

// window:attroff(attrs)
static int lt_curses_window_attroff(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int attrs = luaL_checkint(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(wattroff(w, attrs)));
    return 1;
}

// window:attron(attrs)
static int lt_curses_window_attron(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int attrs = luaL_checkint(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(wattron(w, attrs)));
    return 1;
}

// window:attrset(attrs)
static int lt_curses_window_attrset(lua_State* lua)
{
    WINDOW* w = lt_curses_window_check(lua, 1);
    int attrs = luaL_checkint(lua, 2);
    lua_pushboolean(lua, LT_CURSES_OK(wattrset(w, attrs)));
    return 1;
}

// window:copywin(...)
static int lt_curses_window_copywin(lua_State* lua)
{
    WINDOW* srcwin = lt_curses_window_check(lua, 1);
    WINDOW* dstwin = lt_curses_window_check(lua, 2);
    int sminrow = luaL_checkint(lua, 3);
    int smincol = luaL_checkint(lua, 4);
    int dminrow = luaL_checkint(lua, 5);
    int dmincol = luaL_checkint(lua, 6);
    int dmaxrow = luaL_checkint(lua, 7);
    int dmaxcol = luaL_checkint(lua, 8);
    int overlay = lua_toboolean(lua, 9);
    lua_pushboolean(lua, LT_CURSES_OK(copywin(srcwin, dstwin, sminrow,
        smincol, dminrow, dmincol, dmaxrow, dmaxcol, overlay)));
    return 1;
}

// clean window after exiting program
static void lt_curses_cleanup()
{
    if (!isendwin())
    {
        wclear(stdscr);
        wrefresh(stdscr);
        endwin();
    }
}

// register constants
static void lt_curses_register_constants(lua_State* lua)
{
    // colors
    LT_CURSES_CONST(COLOR_BLACK)
    LT_CURSES_CONST(COLOR_RED)
    LT_CURSES_CONST(COLOR_GREEN)
    LT_CURSES_CONST(COLOR_YELLOW)
    LT_CURSES_CONST(COLOR_BLUE)
    LT_CURSES_CONST(COLOR_MAGENTA)
    LT_CURSES_CONST(COLOR_CYAN)
    LT_CURSES_CONST(COLOR_WHITE)

    // alternate character set
    LT_CURSES_CONST(ACS_BLOCK)
    LT_CURSES_CONST(ACS_BOARD)
    LT_CURSES_CONST(ACS_BTEE)
    LT_CURSES_CONST(ACS_TTEE)
    LT_CURSES_CONST(ACS_LTEE)
    LT_CURSES_CONST(ACS_RTEE)
    LT_CURSES_CONST(ACS_LLCORNER)
    LT_CURSES_CONST(ACS_LRCORNER)
    LT_CURSES_CONST(ACS_URCORNER)
    LT_CURSES_CONST(ACS_ULCORNER)
    LT_CURSES_CONST(ACS_LARROW)
    LT_CURSES_CONST(ACS_RARROW)
    LT_CURSES_CONST(ACS_UARROW)
    LT_CURSES_CONST(ACS_DARROW)
    LT_CURSES_CONST(ACS_HLINE)
    LT_CURSES_CONST(ACS_VLINE)
    LT_CURSES_CONST(ACS_BULLET)
    LT_CURSES_CONST(ACS_CKBOARD)
    LT_CURSES_CONST(ACS_LANTERN)
    LT_CURSES_CONST(ACS_DEGREE)
    LT_CURSES_CONST(ACS_DIAMOND)
    LT_CURSES_CONST(ACS_PLMINUS)
    LT_CURSES_CONST(ACS_PLUS)
    LT_CURSES_CONST(ACS_S1)
    LT_CURSES_CONST(ACS_S9)

    // attributes
    LT_CURSES_CONST(A_NORMAL)
    LT_CURSES_CONST(A_STANDOUT)
    LT_CURSES_CONST(A_UNDERLINE)
    LT_CURSES_CONST(A_REVERSE)
    LT_CURSES_CONST(A_BLINK)
    LT_CURSES_CONST(A_DIM)
    LT_CURSES_CONST(A_BOLD)
    LT_CURSES_CONST(A_PROTECT)
    LT_CURSES_CONST(A_INVIS)
    LT_CURSES_CONST(A_ALTCHARSET)
    LT_CURSES_CONST(A_CHARTEXT)

    // key functions
    LT_CURSES_CONST(KEY_BREAK)
    LT_CURSES_CONST(KEY_DOWN)
    LT_CURSES_CONST(KEY_UP)
    LT_CURSES_CONST(KEY_LEFT)
    LT_CURSES_CONST(KEY_RIGHT)
    LT_CURSES_CONST(KEY_HOME)
    LT_CURSES_CONST(KEY_BACKSPACE)

    LT_CURSES_CONST(KEY_DL)
    LT_CURSES_CONST(KEY_IL)
    LT_CURSES_CONST(KEY_DC)
    LT_CURSES_CONST(KEY_IC)
    LT_CURSES_CONST(KEY_EIC)
    LT_CURSES_CONST(KEY_CLEAR)
    LT_CURSES_CONST(KEY_EOS)
    LT_CURSES_CONST(KEY_EOL)
    LT_CURSES_CONST(KEY_SF)
    LT_CURSES_CONST(KEY_SR)
    LT_CURSES_CONST(KEY_NPAGE)
    LT_CURSES_CONST(KEY_PPAGE)
    LT_CURSES_CONST(KEY_STAB)
    LT_CURSES_CONST(KEY_CTAB)
    LT_CURSES_CONST(KEY_CATAB)
    LT_CURSES_CONST(KEY_ENTER)
    LT_CURSES_CONST(KEY_SRESET)
    LT_CURSES_CONST(KEY_RESET)
    LT_CURSES_CONST(KEY_PRINT)
    LT_CURSES_CONST(KEY_LL)
    LT_CURSES_CONST(KEY_A1)
    LT_CURSES_CONST(KEY_A3)
    LT_CURSES_CONST(KEY_B2)
    LT_CURSES_CONST(KEY_C1)
    LT_CURSES_CONST(KEY_C3)
    LT_CURSES_CONST(KEY_BTAB)
    LT_CURSES_CONST(KEY_BEG)
    LT_CURSES_CONST(KEY_CANCEL)
    LT_CURSES_CONST(KEY_CLOSE)
    LT_CURSES_CONST(KEY_COMMAND)
    LT_CURSES_CONST(KEY_COPY)
    LT_CURSES_CONST(KEY_CREATE)
    LT_CURSES_CONST(KEY_END)
    LT_CURSES_CONST(KEY_EXIT)
    LT_CURSES_CONST(KEY_FIND)
    LT_CURSES_CONST(KEY_HELP)
    LT_CURSES_CONST(KEY_MARK)
    LT_CURSES_CONST(KEY_MESSAGE)
#ifdef PDCURSES
    // https://github.com/xmake-io/xmake/issues/1610#issuecomment-971149885
    LT_CURSES_CONST(KEY_C2)
    LT_CURSES_CONST(KEY_A2)
    LT_CURSES_CONST(KEY_B1)
    LT_CURSES_CONST(KEY_B3)
#endif
#if !defined(XCURSES)
#   ifndef NOMOUSE
    LT_CURSES_CONST(KEY_MOUSE)
#   endif
#endif
    LT_CURSES_CONST(KEY_MOVE)
    LT_CURSES_CONST(KEY_NEXT)
    LT_CURSES_CONST(KEY_OPEN)
    LT_CURSES_CONST(KEY_OPTIONS)
    LT_CURSES_CONST(KEY_PREVIOUS)
    LT_CURSES_CONST(KEY_REDO)
    LT_CURSES_CONST(KEY_REFERENCE)
    LT_CURSES_CONST(KEY_REFRESH)
    LT_CURSES_CONST(KEY_REPLACE)
    LT_CURSES_CONST(KEY_RESIZE)
    LT_CURSES_CONST(KEY_RESTART)
    LT_CURSES_CONST(KEY_RESUME)
    LT_CURSES_CONST(KEY_SAVE)
    LT_CURSES_CONST(KEY_SBEG)
    LT_CURSES_CONST(KEY_SCANCEL)
    LT_CURSES_CONST(KEY_SCOMMAND)
    LT_CURSES_CONST(KEY_SCOPY)
    LT_CURSES_CONST(KEY_SCREATE)
    LT_CURSES_CONST(KEY_SDC)
    LT_CURSES_CONST(KEY_SDL)
    LT_CURSES_CONST(KEY_SELECT)
    LT_CURSES_CONST(KEY_SEND)
    LT_CURSES_CONST(KEY_SEOL)
    LT_CURSES_CONST(KEY_SEXIT)
    LT_CURSES_CONST(KEY_SFIND)
    LT_CURSES_CONST(KEY_SHELP)
    LT_CURSES_CONST(KEY_SHOME)
    LT_CURSES_CONST(KEY_SIC)
    LT_CURSES_CONST(KEY_SLEFT)
    LT_CURSES_CONST(KEY_SMESSAGE)
    LT_CURSES_CONST(KEY_SMOVE)
    LT_CURSES_CONST(KEY_SNEXT)
    LT_CURSES_CONST(KEY_SOPTIONS)
    LT_CURSES_CONST(KEY_SPREVIOUS)
    LT_CURSES_CONST(KEY_SPRINT)
    LT_CURSES_CONST(KEY_SREDO)
    LT_CURSES_CONST(KEY_SREPLACE)
    LT_CURSES_CONST(KEY_SRIGHT)
    LT_CURSES_CONST(KEY_SRSUME)
    LT_CURSES_CONST(KEY_SSAVE)
    LT_CURSES_CONST(KEY_SSUSPEND)
    LT_CURSES_CONST(KEY_SUNDO)
    LT_CURSES_CONST(KEY_SUSPEND)
    LT_CURSES_CONST(KEY_UNDO)

    // KEY_Fx  0 <= x <= 63
    LT_CURSES_CONST(KEY_F0)
    LT_CURSES_CONST2(KEY_F1, KEY_F(1))
    LT_CURSES_CONST2(KEY_F2, KEY_F(2))
    LT_CURSES_CONST2(KEY_F3, KEY_F(3))
    LT_CURSES_CONST2(KEY_F4, KEY_F(4))
    LT_CURSES_CONST2(KEY_F5, KEY_F(5))
    LT_CURSES_CONST2(KEY_F6, KEY_F(6))
    LT_CURSES_CONST2(KEY_F7, KEY_F(7))
    LT_CURSES_CONST2(KEY_F8, KEY_F(8))
    LT_CURSES_CONST2(KEY_F9, KEY_F(9))
    LT_CURSES_CONST2(KEY_F10, KEY_F(10))
    LT_CURSES_CONST2(KEY_F11, KEY_F(11))
    LT_CURSES_CONST2(KEY_F12, KEY_F(12))

#if !defined(XCURSES)
#   ifndef NOMOUSE
    // mouse constants
    LT_CURSES_CONST(BUTTON1_RELEASED)
    LT_CURSES_CONST(BUTTON1_PRESSED)
    LT_CURSES_CONST(BUTTON1_CLICKED)
    LT_CURSES_CONST(BUTTON1_DOUBLE_CLICKED)
    LT_CURSES_CONST(BUTTON1_TRIPLE_CLICKED)
    LT_CURSES_CONST(BUTTON2_RELEASED)
    LT_CURSES_CONST(BUTTON2_PRESSED)
    LT_CURSES_CONST(BUTTON2_CLICKED)
    LT_CURSES_CONST(BUTTON2_DOUBLE_CLICKED)
    LT_CURSES_CONST(BUTTON2_TRIPLE_CLICKED)
    LT_CURSES_CONST(BUTTON3_RELEASED)
    LT_CURSES_CONST(BUTTON3_PRESSED)
    LT_CURSES_CONST(BUTTON3_CLICKED)
    LT_CURSES_CONST(BUTTON3_DOUBLE_CLICKED)
    LT_CURSES_CONST(BUTTON3_TRIPLE_CLICKED)
    LT_CURSES_CONST(BUTTON4_RELEASED)
    LT_CURSES_CONST(BUTTON4_PRESSED)
    LT_CURSES_CONST(BUTTON4_CLICKED)
    LT_CURSES_CONST(BUTTON4_DOUBLE_CLICKED)
    LT_CURSES_CONST(BUTTON4_TRIPLE_CLICKED)
    LT_CURSES_CONST(BUTTON_CTRL)
    LT_CURSES_CONST(BUTTON_SHIFT)
    LT_CURSES_CONST(BUTTON_ALT)
    LT_CURSES_CONST(REPORT_MOUSE_POSITION)
    LT_CURSES_CONST(ALL_MOUSE_EVENTS)
#       if NCURSES_MOUSE_VERSION > 1
    LT_CURSES_CONST(BUTTON5_RELEASED)
    LT_CURSES_CONST(BUTTON5_PRESSED)
    LT_CURSES_CONST(BUTTON5_CLICKED)
    LT_CURSES_CONST(BUTTON5_DOUBLE_CLICKED)
    LT_CURSES_CONST(BUTTON5_TRIPLE_CLICKED)
#       else
    LT_CURSES_CONST(BUTTON1_RESERVED_EVENT)
    LT_CURSES_CONST(BUTTON2_RESERVED_EVENT)
    LT_CURSES_CONST(BUTTON3_RESERVED_EVENT)
    LT_CURSES_CONST(BUTTON4_RESERVED_EVENT)
#       endif
#   endif
#endif
}

// init curses
static int lt_curses_initscr(lua_State* lua)
{
    WINDOW* w = initscr();
    if (!w) return 0;
    lt_curses_window_new(lua, w);

#if defined(NCURSES_VERSION)
    ESCDELAY = 0;
#endif

    lua_pushstring(lua, LT_CURSES_STDSCR);
    lua_pushvalue(lua, -2);
    lua_rawset(lua, LUA_REGISTRYINDEX);

    lt_curses_register_constants(lua);

#ifndef PDCURSES
    atexit(lt_curses_cleanup);
#endif
    return 1;
}

static int lt_curses_endwin(lua_State* lua)
{
    endwin();
#ifdef XCURSES
    XCursesExit();
    exit(0);
#endif
    return 0;
}

static int lt_curses_stdscr(lua_State* lua)
{
    lua_pushstring(lua, LT_CURSES_STDSCR);
    lua_rawget(lua, LUA_REGISTRYINDEX);
    return 1;
}

#if !defined(XCURSES) && !defined(NOMOUSE)
static int lt_curses_getmouse(lua_State* lua)
{
    MEVENT e;
    if (getmouse(&e) == OK)
    {
        lua_pushinteger(lua, e.bstate);
        lua_pushinteger(lua, e.x);
        lua_pushinteger(lua, e.y);
        lua_pushinteger(lua, e.z);
        lua_pushinteger(lua, e.id);
        return 5;
    }

    lua_pushnil(lua);
    return 1;
}

static int lt_curses_mousemask(lua_State* lua)
{
    mmask_t m = luaL_checkint(lua, 1);
    mmask_t om;
    m = mousemask(m, &om);
    lua_pushinteger(lua, m);
    lua_pushinteger(lua, om);
    return 2;
}
#endif

static int lt_curses_init_pair(lua_State* lua)
{
    short pair = luaL_checkint(lua, 1);
    short f = luaL_checkint(lua, 2);
    short b = luaL_checkint(lua, 3);

    lua_pushboolean(lua, LT_CURSES_OK(init_pair(pair, f, b)));
    return 1;
}

static int lt_curses_COLOR_PAIR(lua_State* lua)
{
    int n = luaL_checkint(lua, 1);
    lua_pushnumber(lua, COLOR_PAIR(n));
    return 1;
}

static int lt_curses_curs_set(lua_State* lua)
{
    int vis = luaL_checkint(lua, 1);
    int state = curs_set(vis);
    if (state == ERR)
        return 0;

    lua_pushnumber(lua, state);
    return 1;
}

static int lt_curses_napms(lua_State* lua)
{
    int ms = luaL_checkint(lua, 1);
    lua_pushboolean(lua, LT_CURSES_OK(napms(ms)));
    return 1;
}

static int lt_curses_cbreak(lua_State* lua)
{
    if (lua_isnoneornil(lua, 1) || lua_toboolean(lua, 1))
        lua_pushboolean(lua, LT_CURSES_OK(cbreak()));
    else
        lua_pushboolean(lua, LT_CURSES_OK(nocbreak()));
    return 1;
}

static int lt_curses_echo(lua_State* lua)
{
    if (lua_isnoneornil(lua, 1) || lua_toboolean(lua, 1))
        lua_pushboolean(lua, LT_CURSES_OK(echo()));
    else
        lua_pushboolean(lua, LT_CURSES_OK(noecho()));
    return 1;
}

static int lt_curses_nl(lua_State* lua)
{
    if (lua_isnoneornil(lua, 1) || lua_toboolean(lua, 1))
        lua_pushboolean(lua, LT_CURSES_OK(nl()));
    else
        lua_pushboolean(lua, LT_CURSES_OK(nonl()));
    return 1;
}

static int lt_curses_newpad(lua_State* lua)
{
    int nlines = luaL_checkint(lua, 1);
    int ncols = luaL_checkint(lua, 2);
    lt_curses_window_new(lua, newpad(nlines, ncols));
    return 1;
}

LT_CURSES_NUMBER2(COLS, COLS)
LT_CURSES_NUMBER2(LINES, LINES)
LT_CURSES_BOOL(isendwin)
LT_CURSES_BOOLOK(start_color)
LT_CURSES_BOOL(has_colors)
LT_CURSES_BOOLOK(doupdate)
LT_CURSES_WINDOW_BOOLOK(wclear)
LT_CURSES_WINDOW_BOOLOK(wnoutrefresh)

/* //////////////////////////////////////////////////////////////////////////////////////
 * globals
 */

static const luaL_Reg g_window_functions[] =
{
    { "close",      lt_curses_window_delwin       },
    { "keypad",     lt_curses_window_keypad       },
    { "meta",       lt_curses_window_meta         },
    { "nodelay",    lt_curses_window_nodelay      },
    { "leaveok",    lt_curses_window_leaveok      },
    { "move",       lt_curses_window_move         },
    { "clear",      lt_curses_window_wclear       },
    { "noutrefresh",lt_curses_window_wnoutrefresh },
    { "attroff",    lt_curses_window_attroff      },
    { "attron",     lt_curses_window_attron       },
    { "attrset",    lt_curses_window_attrset      },
    { "getch",      lt_curses_window_getch        },
    { "getyx",      lt_curses_window_getyx        },
    { "getmaxyx",   lt_curses_window_getmaxyx     },
    { "addch",      lt_curses_window_addch        },
    { "addstr",     lt_curses_window_addnstr      },
    { "copy",       lt_curses_window_copywin      },
    {"__gc",        lt_curses_window_delwin       },
    {"__tostring",  lt_curses_window_tostring     },
    {NULL, NULL                                   }
};

static const luaL_Reg g_curses_functions[] =
{
    { "done",           lt_curses_endwin       },
    { "isdone",         lt_curses_isendwin     },
    { "main_window",    lt_curses_stdscr       },
    { "columns",        lt_curses_COLS         },
    { "lines",          lt_curses_LINES        },
    { "start_color",    lt_curses_start_color  },
    { "has_colors",     lt_curses_has_colors   },
    { "init_pair",      lt_curses_init_pair    },
    { "color_pair",     lt_curses_COLOR_PAIR   },
    { "napms",          lt_curses_napms        },
    { "cursor_set",     lt_curses_curs_set     },
    { "new_pad",        lt_curses_newpad       },
    { "doupdate",       lt_curses_doupdate     },
    { "cbreak",         lt_curses_cbreak       },
    { "echo",           lt_curses_echo         },
    { "nl",             lt_curses_nl           },
#if !defined(XCURSES)
#ifndef NOMOUSE
    { "mousemask",      lt_curses_mousemask    },
    { "getmouse",       lt_curses_getmouse     },
#endif
#endif
    {NULL, NULL}
};

/* //////////////////////////////////////////////////////////////////////////////////////
 * implementations
 */
#ifdef __cplusplus
extern "C" {
#endif
__export int luaopen_ltui_lcurses(lua_State* lua)
{
    // create new metatable for window objects
    luaL_newmetatable(lua, LT_CURSES_WINDOW);
    lua_pushliteral(lua, "__index");
    lua_pushvalue(lua, -2);               /* push metatable */
    lua_rawset(lua, -3);                  /* metatable.__index = metatable */
    luaL_setfuncs(lua, g_window_functions, 0);
    lua_pop(lua, 1);                      /* remove metatable from stack */

    // create global table with curses methods/variables/constants
    lua_newtable(lua);
    luaL_setfuncs(lua, g_curses_functions, 0);

    // add curses.init()
    lua_pushstring(lua, "init");
    lua_pushvalue(lua, -2);
    lua_pushcclosure(lua, lt_curses_initscr, 1);
    lua_settable(lua, -3);

    /* Since version 5.4, the ncurses library decides how to interpret non-ASCII data using the nl_langinfo function.
     * That means that you have to call setlocale() in the application and encode Unicode strings using one of the system’s available encodings.
     *
     * And we need link libncursesw.so for drawing vline, hline characters
     */
#if defined(NCURSES_VERSION)
    setlocale(LC_ALL, "");
#endif
    return 1;
}

#ifdef __cplusplus
}
#endif

