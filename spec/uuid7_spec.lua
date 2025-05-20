local uuid7 = require("uuid7")

describe("UUID7", function()
  it("generates a valid UUIDv7 integer array", function()
    local bytes = uuid7.as_table()

    assert.are.equal(16, #bytes)

    -- all values are valid bytes (0-255)
    for _, byte in ipairs(bytes) do
      assert.is_true(byte >= 0 and byte <= 255)
    end

    -- version, 7th byte
    assert.are.equal(7, (bytes[7] >> 4) & 0xf)

    -- variant, 9th byte
    assert.are.equal(2, (bytes[9] >> 6) & 0x3)
  end)

  it("converts a byte table to a valid UUID string", function()
    local bytes = {
      0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x70, 0x08,
      0x80, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10
    }

    local uuid_str = uuid7.to_string(bytes)

    assert.are.equal("01020304-0506-7008-800a-0b0c0d0e0f10", uuid_str)
  end)

  it("generates a valid UUIDv7 string", function()
    local uuid_str = uuid7.generate()

    -- Check format: 8-4-4-4-12 (36 chars with hyphens)
    assert.are.equal(36, #uuid_str)
    assert.is_true(uuid_str:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil)

    -- Check version (position 15, should be 7)
    assert.are.equal("7", uuid_str:sub(15, 15))

    -- Check variant (position 20, should be 8, 9, a, or b)
    assert.is_true(uuid_str:sub(20, 20):match("[89ab]") ~= nil)
  end)
end)
