local TypeID = require("typeid")
local json = require("dkjson")

describe("TypeID", function()
  local function read_json_file(filename)
    local file = io.open(filename, "r")
    if not file then error("Could not open file: " .. filename) end
    local content = file:read("*all")
    file:close()
    return json.decode(content)
  end

  describe("valid prefixes", function()
    it("accepts empty prefix", function()
      local id = TypeID.generate("")
      assert.are.equal("", id.prefix)
    end)

    it("accepts 'user' prefix", function()
      local id = TypeID.generate("user")
      assert.are.equal("user", id.prefix)
    end)

    it("accepts 'my_type' prefix", function()
      local id = TypeID.generate("my_type")
      assert.are.equal("my_type", id.prefix)
    end)

    it("accepts 'a_b_c' prefix", function()
      local id = TypeID.generate("a_b_c")
      assert.are.equal("a_b_c", id.prefix)
    end)

    it("accepts 'my__type' prefix", function()
      local id = TypeID.generate("my__type")
      assert.are.equal("my__type", id.prefix)
    end)

    it("accepts single character 'a' prefix", function()
      local id = TypeID.generate("a")
      assert.are.equal("a", id.prefix)
    end)

    it("accepts 'abcd' prefix", function()
      local id = TypeID.generate("abcd")
      assert.are.equal("abcd", id.prefix)
    end)
  end)

  describe("invalid prefixes", function()
    it("rejects '_foo' prefix (starts with underscore)", function()
      assert.has_error(function()
        TypeID.generate("_foo")
      end, "type prefix cannot start or end with an underscore")
    end)

    it("rejects 'bar_' prefix (ends with underscore)", function()
      assert.has_error(function()
        TypeID.generate("bar_")
      end, "type prefix cannot start or end with an underscore")
    end)

    it("rejects '_' prefix (single underscore)", function()
      assert.has_error(function()
        TypeID.generate("_")
      end, "type prefix cannot start or end with an underscore")
    end)

    it("rejects 'FOO' prefix (uppercase letters)", function()
      assert.has_error(function()
        TypeID.generate("FOO")
      end, "type prefix must be lowercase ASCII characters")
    end)
  end)

  describe("valid.json test cases", function()
    local valid_cases = read_json_file("spec/valid.json")

    for _, test_case in ipairs(valid_cases) do
      it("accepts " .. test_case.name, function()
        local typeid_str = test_case.typeid
        local expected_prefix = test_case.prefix
        local expected_uuid = test_case.uuid

        local id = TypeID.parse(typeid_str)
        assert.are.equal(expected_prefix, id.prefix)

        -- test that we can create the same TypeID from the UUID
        if expected_uuid ~= "00000000-0000-0000-0000-000000000000" then
          local id_from_uuid = TypeID.from_uuid_string(expected_prefix, expected_uuid)
          assert.are.equal(tostring(id), tostring(id_from_uuid))
        end
      end)
    end
  end)

  describe("invalid.json test cases", function()
    local invalid_cases = read_json_file("spec/invalid.json")

    for _, test_case in ipairs(invalid_cases) do
      it("rejects " .. test_case.name .. ": " .. test_case.description, function()
        local typeid_str = test_case.typeid

        -- bleh, really should test the specific validation errors
        assert.has_error(function()
          TypeID.parse(typeid_str)
        end)
      end)
    end
  end)

  describe("uuid method", function()
    it("converts TypeID to UUID string format", function()
      local id = TypeID.new("user", "01h455vb4pex5vsknk084sn02q")

      local uuid_str = id:uuid()
      assert.truthy(uuid_str:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"))

      -- round trip
      local known_id = TypeID.from_uuid_string("test", "01893726-efee-7f02-8fbf-9f2b7bc2f910")
      local uuid_known = known_id:uuid()
      assert.are.equal("01893726-efee-7f02-8fbf-9f2b7bc2f910", uuid_known)
    end)
  end)
end)
