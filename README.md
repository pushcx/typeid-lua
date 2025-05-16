
# TypeID in Lua

This is an implementation of [TypeID](https://github.com/jetify-com/typeid) [0.3.0](https://github.com/jetify-com/typeid/tree/main/spec) in Lua.

There's some C to get a timestamp in milliseconds, which is required to generate a [UUID7](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_7_\(timestamp_and_random\)).
Lua's `os.time()` gives timestamps in seconds, presumably for maximum portability.
Hopefully this is reasonably portable, but if not it's short enough to be reasonably replaced.

**Maturity**: this was a toy project for me to practice Lua.
It works and has reasonable tests, including passing the TypeID suite.
It's probably not idiomatic Lua.


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


# Ideas

 * I experimented with style.
   `TypeID` is more OO style, `Base32` and `UUID7` work on primitives.
   After implementing, I guess users would probably prefer getting a primitive back, despite the lack of types.
 * The nested conversions in the metatable `uuid` function suggests the internal representation of `suffix` is wrong,
   but the syntactic distinction between `.field` and `:method()` means duplicating the data into two fields, exposing the internal representation by it being a field and the other a method, or getting away from what seems like common struct-y style and making both methods.
   I don't really know what level to aim at between "nice consistent high-level interface" and "damn everything, all primitives and seams showing for perf".
 * The rockspec probably does not correctly depend on `sys/time.h`.
 * I ported Base32 from the official TypeID Golang implementation then wrote UUID7 in bytes to match it,
   but all that intermediate bit twiddling could be simplified by generating a UUID7 directly into the Base32 encoding.
 * Maybe I'm looking under the wrong name, but it seems odd there isn't a bitfield type I could use, given Lua's popularity in games.
   Some searching turned up [a library](https://github.com/JohnHind/Lua_Bitfield) but the absence of multi-bit operations seems inconvenient.
 * Spec says "Implementations SHOULD allow encoding/decoding of other UUID variants" but does not mandate validating them, so I don't.
   Perhaps the spec should say implementations should not permit any old 128 bits.
