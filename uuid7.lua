local UUID7 = {}
local millitime = require("millitime")

local VERSION_7 = 0x7000
local VARIANT_RFC4122 = 0x8000

-- generate a UUIDv7 as a length 16 table of one-byte integers
function UUID7.as_table(timestamp, seed)
  -- use current time if no timestamp provided
  timestamp = timestamp or millitime.time()
  -- seed is for tests
  math.randomseed(seed or millitime.time())

  -- extract low 48 bits/6 bytes from timestamp
  local ts = timestamp & 0xffffffffffff

  -- random for the remaining 80 bits/10 bytes
  local r7 = math.random(0, 0xff)
  local r8 = math.random(0, 0xff)
  local r9 = math.random(0, 0xff)
  local r10 = math.random(0, 0xff)
  local r11 = math.random(0, 0xff)
  local r12 = math.random(0, 0xff)
  local r13 = math.random(0, 0xff)
  local r14 = math.random(0, 0xff)
  local r15 = math.random(0, 0xff)
  local r16 = math.random(0, 0xff)

  return {
    -- bytes 1-6: timestamp (48 bits)
    (ts >> 40) & 0xff,
    (ts >> 32) & 0xff,
    (ts >> 24) & 0xff,
    (ts >> 16) & 0xff,
    (ts >> 8) & 0xff,
    ts & 0xff,

    -- 7th byte: random mask with version 7
    (VERSION_7 >> 8) | (r7 & 0x0f),

    -- 8th byte: random
    r8,

    -- 9th byte: random mask with variant
    0x80 | (r9 & 0x3f),

    -- 10th byte: random
    r10,

    -- 6 bytes 11-12: random
    r11, r12, r13, r14, r15, r16
  }
end

-- convert a 16-byte table to a standard UUID string
function UUID7.to_string(bytes)
  if not bytes or #bytes ~= 16 then
    error("UUID must be a 16-byte table")
  end

  return string.format(
    "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
    bytes[1], bytes[2], bytes[3], bytes[4],
    bytes[5], bytes[6],
    bytes[7], bytes[8],
    bytes[9], bytes[10],
    bytes[11], bytes[12], bytes[13], bytes[14], bytes[15], bytes[16]
  )
end


-- generate a UUIDv7 as a standard UUID string
function UUID7.generate(timestamp, seed)
  return UUID7.to_string(UUID7.as_table(timestamp, seed))
end

return UUID7
