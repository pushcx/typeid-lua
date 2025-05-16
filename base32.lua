-- This is not a general-purpose encoder and decoder for all strings, it only
-- works on UUIDs.
--
-- Ported from https://github.com/jetify-com/typeid-go/blob/5c084b87132053828b438b81e6d36247674c25b0/base32/base32.go
local Base32 = {}

-- Crockford's Base32 alphabet
Base32.ALPHABET = {
  [0]= -- index lookup table from 0, not 1
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
  "a", "b", "c", "d", "e", "f", "g", "h", "j", "k",
  "m", "n", "p", "q", "r", "s", "t", "v", "w", "x",
  "y", "z",
}

-- encode a length 16 one-byte integer table into a size 26 string
function Base32.encode(id)
  if #id ~= 16 then
    error("invalid id size")
  end

  local str = {}

  -- 10 byte timestamp
  str[1]  = Base32.ALPHABET[(id[1] & 224) >> 5]
  str[2]  = Base32.ALPHABET[id[1] & 31]
  str[3]  = Base32.ALPHABET[(id[2] & 248) >> 3]
  str[4]  = Base32.ALPHABET[((id[2] & 7) << 2) | ((id[3] & 192) >> 6)]
  str[5]  = Base32.ALPHABET[(id[3] & 62) >> 1]
  str[6]  = Base32.ALPHABET[((id[3]&1) << 4) | ((id[4] & 240) >> 4)]
  str[7]  = Base32.ALPHABET[((id[4] & 15) << 1) | ((id[5] & 128) >> 7)]
  str[8]  = Base32.ALPHABET[(id[5] & 124) >> 2]
  str[9]  = Base32.ALPHABET[((id[5] & 3) << 3) | ((id[6] & 224) >> 5)]
  str[10] = Base32.ALPHABET[id[6] & 31]

  -- 16 bytes of entropy
  str[11] = Base32.ALPHABET[(id[7] & 248) >> 3]
  str[12] = Base32.ALPHABET[((id[7] & 7) << 2) | ((id[8] & 192) >> 6)]
  str[13] = Base32.ALPHABET[(id[8] & 62) >> 1]
  str[14] = Base32.ALPHABET[((id[8] & 1) << 4) | ((id[9] & 240) >> 4)]
  str[15] = Base32.ALPHABET[((id[9] & 15) << 1) | ((id[10] & 128) >> 7)]
  str[16] = Base32.ALPHABET[(id[10] & 124) >> 2]
  str[17] = Base32.ALPHABET[((id[10] & 3) << 3) | ((id[11] & 224) >> 5)]
  str[18] = Base32.ALPHABET[id[11] & 31]
  str[19] = Base32.ALPHABET[(id[12] & 248) >> 3]
  str[20] = Base32.ALPHABET[((id[12] & 7) << 2) | ((id[13] & 192) >> 6)]
  str[21] = Base32.ALPHABET[(id[13] & 62) >> 1]
  str[22] = Base32.ALPHABET[((id[13] & 1) << 4) | ((id[14] & 240) >> 4)]
  str[23] = Base32.ALPHABET[((id[14] & 15) << 1) | ((id[15] & 128) >> 7)]
  str[24] = Base32.ALPHABET[(id[15] & 124) >> 2]
  str[25] = Base32.ALPHABET[((id[15] & 3) << 3) | ((id[16] & 224) >> 5)]
  str[26] = Base32.ALPHABET[id[16] & 31]

  return table.concat(str)
end

-- byte -> index lookup table for O(1) lookups when unmarshaling
-- 0xFF is a sentinel value for invalid indexes
Base32.DEC = {
  [0]= -- index lookup table from 0, not 1
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x01,
  0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x0A, 0x0B, 0x0C,
  0x0D, 0x0E, 0x0F, 0x10, 0x11, 0xFF, 0x12, 0x13, 0xFF, 0x14,
  0x15, 0xFF, 0x16, 0x17, 0x18, 0x19, 0x1A, 0xFF, 0x1B, 0x1C,
  0x1D, 0x1E, 0x1F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
  0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
}


-- decode a length 26 string into a size 16 byte table
function Base32.decode(str)
  if #str ~= 26 then
    error("invalid length")
  end

  local bytes = {string.byte(str, 1, -1)}

  -- Check for invalid characters
  for i = 1, #bytes do
    if Base32.DEC[bytes[i]] == 0xFF then
      error(string.format("invalid base32 character at position %s: %s", i, bytes[i]))
    end
  end

  local id = {}

  -- the original go wraps, we & 0xFF, equivalent to % 256

  -- 48 bits/6 bytes timestamp
  id[1]  = ((Base32.DEC[bytes[1]] << 5) | Base32.DEC[bytes[2]]) & 0xFF
  id[2]  = ((Base32.DEC[bytes[3]] << 3) | (Base32.DEC[bytes[4]] >> 2)) & 0xFF
  id[3]  = ((Base32.DEC[bytes[4]] << 6) | (Base32.DEC[bytes[5]] << 1) | (Base32.DEC[bytes[6]] >> 4)) & 0xFF
  id[4]  = ((Base32.DEC[bytes[6]] << 4) | (Base32.DEC[bytes[7]] >> 1)) & 0xFF
  id[5]  = ((Base32.DEC[bytes[7]] << 7) | (Base32.DEC[bytes[8]] << 2) | (Base32.DEC[bytes[9]] >> 3)) & 0xFF
  id[6]  = ((Base32.DEC[bytes[9]] << 5) | Base32.DEC[bytes[10]]) & 0xFF

  -- 80 bits/10 bytes of entropy
  id[7]  = ((Base32.DEC[bytes[11]] << 3) | (Base32.DEC[bytes[12]] >> 2)) & 0xFF-- First 4 bits are the version
  id[8]  = ((Base32.DEC[bytes[12]] << 6) | (Base32.DEC[bytes[13]] << 1) | (Base32.DEC[bytes[14]] >> 4)) & 0xFF
  id[9]  = ((Base32.DEC[bytes[14]] << 4) | (Base32.DEC[bytes[15]] >> 1)) & 0xFF -- First 2 bits are the bytesariant
  id[10] = ((Base32.DEC[bytes[15]] << 7) | (Base32.DEC[bytes[16]] << 2) | (Base32.DEC[bytes[17]] >> 3)) & 0xFF
  id[11] = ((Base32.DEC[bytes[17]] << 5) | Base32.DEC[bytes[18]]) & 0xFF
  id[12] = ((Base32.DEC[bytes[19]] << 3) | (Base32.DEC[bytes[20]] >> 2)) & 0xFF
  id[13] = ((Base32.DEC[bytes[20]] << 6) | (Base32.DEC[bytes[21]] << 1) | (Base32.DEC[bytes[22]] >> 4)) & 0xFF
  id[14] = ((Base32.DEC[bytes[22]] << 4) | (Base32.DEC[bytes[23]] >> 1)) & 0xFF
  id[15] = ((Base32.DEC[bytes[23]] << 7) | (Base32.DEC[bytes[24]] << 2) | (Base32.DEC[bytes[25]] >> 3)) & 0xFF
  id[16] = ((Base32.DEC[bytes[25]] << 5) | Base32.DEC[bytes[26]]) & 0xFF

  return id
end

return Base32
