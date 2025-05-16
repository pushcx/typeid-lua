local Base32 = require("base32")

describe("Base32", function()
  local decoded = {1, 136, 186, 199, 74, 250, 120, 170, 188, 59, 189, 30, 239, 40, 216, 129}
  local encoded = "01h2xcejqtf2nbrexx3vqjhp41"

  describe("encode", function()
    it("encodes a byte array to a base32 string", function()
      local result = Base32.encode(decoded)

      assert.are.equal(encoded, result)
    end)
  end)

  describe("decode", function()
    it("decodes a base32 string to a byte array", function()
      local result = Base32.decode(encoded)

      assert.are.same(decoded, result)
    end)
  end)
end)
