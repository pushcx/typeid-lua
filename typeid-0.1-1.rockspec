-- https://github.com/luarocks/luarocks/blob/main/docs/creating_a_rock.md
package = "typeid"
version = "0.1-1"
source = {
   url = "https://github.com/pushcx/typeid-lua",
   tag = "v0.1-1"
}
description = {
   summary = "Implementation of TypeID in Lua",
   homepage = "https://github.com/pushcx/typeid-lua",
   license = "Apache 2.0"
}
dependencies = {
   "lua >= 5.1",
   "dkjson >= 2.5" -- only for tests
}
build = {
   type = "builtin",
   modules = {
     typeid = "typeid.lua",
     millitime = {
       sources = {"millitime.c"},
       incdirs = {"$(LUA_INCDIR)"},
     }
   }
}
