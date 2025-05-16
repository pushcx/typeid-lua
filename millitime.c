#include <sys/time.h>

#include "lua.h"
#include "lauxlib.h"

static int time(lua_State *L) {
    struct timeval time;
    gettimeofday(&time, NULL);
    lua_Number milliseconds = (time.tv_sec * 1000) + (time.tv_usec / 1000);
    lua_pushnumber(L, milliseconds);

    return 1;
}

int luaopen_millitime(lua_State *L) {
    static const luaL_Reg mylib [] = {
        {"time", time},
        {NULL, NULL}
    };

    lua_newtable(L);
#if LUA_VERSION_NUM > 501
    luaL_setfuncs(L, mylib, 0);
#else
    luaL_register(L, NULL, mylib);
#endif
    return 1;
}
