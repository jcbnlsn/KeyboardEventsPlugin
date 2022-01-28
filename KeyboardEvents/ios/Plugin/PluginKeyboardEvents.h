//
//  PluginKeyboardEvents.h
//
//  Copyright (c) 2017 Jacob Nielsen. All rights reserved.
//

#ifndef _PluginKeyboardEvents_H__
#define _PluginKeyboardEvents_H__

#include <CoronaLua.h>
#include <CoronaMacros.h>

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
// where the '.' is replaced with '_'
CORONA_EXPORT int luaopen_plugin_keyboardEvents( lua_State *L );

#endif // _PluginKeyboardEvents_H__
