local Base32 = require("base32")
local millitime = require("millitime")
local UUID7 = require("uuid7")

local TypeID = {}
TypeID.MAX_PREFIX_LENGTH = 63

-- prefix string, suffix a Base32 string
function TypeID.new(prefix, suffix)
  if not prefix then
    error("no prefix specified, though empty string would be valid")
  end

  -- spec: Valid prefixes match the following regex: ^([a-z]([a-z_]{0,61}[a-z])?)?$
  -- Lua's patterns aren't expressive enough to paste that in, but these checks
  -- match that and give more specific errors, to boot.
  if #prefix > TypeID.MAX_PREFIX_LENGTH then
    error("type prefix length cannot be greater than " .. TypeID.MAX_PREFIX_LENGTH)
  end

  if not prefix:match("^[a-z_]*$") then
    error("type prefix must be lowercase ASCII characters")
  end

  if prefix:match("^_") or prefix:match("_$") then
    error("type prefix cannot start or end with an underscore")
  end

  if #suffix ~= 26 then
    error("UUID suffix must be 26 characters, is " .. #suffix)
  end

  if not suffix:match("^[0123456789abcdefghjkmnpqrstvwxyz]*$") then
    error("UUID suffix must only use Base32 characters")
  end

  -- check if suffix starts with a 0-7 digit
  local first_char = suffix:sub(1, 1)
  if not first_char:match("[0-7]") then
    error("UUID suffix must start with a 0-7 digit to avoid overflows")
  end

  local typeid = {
    prefix = prefix,
    suffix = suffix,

    uuid = function(self)
      return UUID7.to_string(Base32.decode(self.suffix))
    end
  }

  setmetatable(typeid, {
    __tostring = function(self)
      if self.prefix == "" then
        return self.suffix
      else
        return self.prefix .. "_" .. self.suffix
      end
    end
  })

  return typeid
end

-- create a TypeID with the given prefix, optional millisecond timestamp and seed
-- (seed is probably only useful for tests)
function TypeID.generate(prefix, timestamp, seed)
  local uuid_bytes = UUID7.as_table(timestamp, seed)
  local suffix = Base32.encode(uuid_bytes)
  return TypeID.new(prefix, suffix)
end

-- parse a TypeID from a string like "prefix_01h455vb4pex5vsknk084sn02q"
function TypeID.parse(str)
  local prefix, suffix

  local last_underscore_pos = str:match(".*_()") -- Find position after the last underscore
  if not last_underscore_pos then
    prefix = ""
    suffix = str
  else
    prefix = str:sub(1, last_underscore_pos - 2) -- -2 because match returns position after underscore
    suffix = str:sub(last_underscore_pos)

    if prefix == "" then
      error("prefix cannot be empty when there's a separator")
    end
  end

  return TypeID.new(prefix, suffix)
end

-- create a TypeID from a prefix and a UUID string
function TypeID.from_uuid_string(prefix, uuid_str)
  local uuid_bytes = {}

  -- parse groups from UUID string like "01893726-efee-7f02-8fbf-9f2b7bc2f910"
  local g1, g2, g3, g4, g5 = uuid_str:match("(%x%x%x%x%x%x%x%x)%-(%x%x%x%x)%-(%x%x%x%x)%-(%x%x%x%x)%-(%x%x%x%x%x%x%x%x%x%x%x%x)")

  if not g1 then
    error("invalid UUID format")
  end

  -- convert hex to bytes
  local function hex_to_bytes(hex)
    local bytes = {}
    for i = 1, #hex, 2 do
      local byte = tonumber(hex:sub(i, i+1), 16)
      table.insert(bytes, byte)
    end
    return bytes
  end

  local bytes1 = hex_to_bytes(g1)
  local bytes2 = hex_to_bytes(g2)
  local bytes3 = hex_to_bytes(g3)
  local bytes4 = hex_to_bytes(g4)
  local bytes5 = hex_to_bytes(g5)

  -- combine all bytes
  for _, b in ipairs(bytes1) do table.insert(uuid_bytes, b) end
  for _, b in ipairs(bytes2) do table.insert(uuid_bytes, b) end
  for _, b in ipairs(bytes3) do table.insert(uuid_bytes, b) end
  for _, b in ipairs(bytes4) do table.insert(uuid_bytes, b) end
  for _, b in ipairs(bytes5) do table.insert(uuid_bytes, b) end

  local suffix = Base32.encode(uuid_bytes)
  return TypeID.new(prefix, suffix)
end

return TypeID
