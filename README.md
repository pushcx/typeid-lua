
# TypeID in Lua

https://luarocks.org/modules/pushcx/typeid

This is an implementation of [TypeID](https://github.com/jetify-com/typeid) [0.3.0](https://github.com/jetify-com/typeid/tree/main/spec) in Lua.

There's some C to get a timestamp in milliseconds, which is required to generate a [UUID7](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_7_\(timestamp_and_random\)).
Lua's `os.time()` gives timestamps in seconds, presumably for maximum portability.
Hopefully this is reasonably portable, but if not it's short enough to be reasonably replaced.

**Maturity**: this was a toy project for me to practice Lua.
It works and has good tests, including passing the TypeID suite.
It's probably not idiomatic Lua.

I've written up some notes on the implementation and alternatives in the [announcement blog post](https://push.cx/typeid-in-lua).


# Use

```lua
TypeID = require("typeid")
-- or in dev: TypeID = require("./typeid")

t = TypeID.generate("comment")
-- t = {
--   prefix = "comment",
--   suffix = "01jvbhbbdje07rnyqkvstpvcge"
-- }

-- TypeID tables implement __tostring
print(t) -- "comment_01jvbhbbdje07rnyqkvstpvcge"

-- You can extract a standard UUID string
t:uuid() -- "0196d715-adb2-700f-8afa-f3de756db20e"

-- and round trip that back into a TypeID
TypeID.from_uuid_string("comment", "0196d715-adb2-700f-8afa-f3de756db20e")

-- parse and validate a TypeID from a string
TypeID.parse("comment_01jvbhbbdje07rnyqkvstpvcge")

-- finally, you can generate with a unix timestamp in ms:
TypeID.generate("comment", 1) -- "comment_0000000001e8avt0nh7a68v2jc"
```


# Build

```
# build and install
$ luarocks make

# build for development
$ luarocks make --no-install
```


# Test

```
$ busted --shuffle
●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●●
47 successes / 0 failures / 0 errors / 0 pending : 0.019008 seconds
```

# Likely Issues

 * The rockspec probably does not correctly depend on `sys/time.h`.
 * I don't understand why `luarocks` generated the version `0.1-1`, what is the `-1` for?
   Is my version `0.1` or `0.1-1`?
 * The TypeID spec says "Implementations SHOULD allow encoding/decoding of other UUID variants" but does not mandate validating them, so I don't.
   Perhaps the spec should say implementations should not permit any old 128 bits.
