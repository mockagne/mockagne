--- Mockagne - Lua Mock Library
-- https://github.com/PunchWolf/mockagne
--
-- @copyright 2013 Punch Wolf Game Studios
-- @author Janne Sinivirta
-- @author Marko Pukari

package.path = package.path .. ";../?.lua"

local mockagne = require "mockagne"

local t = nil
local when = mockagne.when
local any = mockagne.anyType
local verify = mockagne.verify

describe("When testing mockagne", function ()
	before_each(function()
		t = mockagne.getMock()
	end)

	it("no argument function", function()
		local returns = t.foo()

		verify(t.foo())
		assert.equal(nil, returns)
	end)

	it("no invocation", function ()
		-- no call made to t

		assert.has_error(function() verify(t.foo()) end)
	end)

	it("two no argument calls", function()
		t.foo()
		t.bar()

		verify(t.bar())
		verify(t.foo())
	end)

	it("single argument function", function()
		t.foo("bar")
		verify(t.foo("bar"))
	end)

	it("single argument passed to function is self", function()
		t.foo(t)

		verify(t.foo(t))
	end)

	it("double argument function", function()
		t.foo("bar", "baz")

		verify(t.foo("bar", "baz"))
	end)

	it("single table argument", function()
		local variable = {name = "var"}

		t.foo(variable)

		verify(t.foo(variable))
	end)

	it("empty anyType with one parameter", function()
		local variable = {name = "var"}

		t.foo(variable)

		verify(t.foo(any()))
	end)

	it("empty anyType with not enough parameters", function()
		local variable = {name = "var"}

		t.foo(variable, "bar")

		assert.has_error(function() verify(t.foo(any())) end)
	end)

	it("empty anyType with all parameters", function()
		local variable = {name = "var"}

		t.foo(variable, "bar")

		verify(t.foo(any(), "bar"))
	end)

	it("multiple anyType parameters", function()
		t.foo("bar", "baz")

		t:verify("foo", any(), any())
	end)

	it("empty anyType with no called parameter", function()
		t.foo()

		assert.has_error(function() assert.has_error(verify(t.foo(any()))) end)
	end)

	it("typed anyType with one parameter", function()
		local variable = {name = "var"}

		t.foo(variable)

		verify(t.foo(any({})))
	end)

	it("typed anyType with one non-type-matching parameter", function()
		local variable = {name = "var"}

		t.foo("bar")

		assert.has_error(function() verify(t.foo(any({}))) end)
	end)

	it("typed anyType with two matching parameters", function()
		local variable = {name = "var"}

		t.foo(variable, "bar")

		verify(t.foo(variable, any("")))
	end)

	it("typed anyType with no called parameters", function()
		t.foo()

		assert.has_error(function() verify(t.foo(any({}))) end)
	end)

	it("wrong argument", function()
		t.foo("bar")

		assert.has_error(function() verify(t.foo("dork")) end)
	end)

	it("wrong function name", function()
		t.foo("bar")

		assert.has_error(function() verify(t.dork("bar")) end)
	end)

	it("wrong table argument", function()
		local variable = {name = "var"}
		local wrong_variable = {name = "var"}

		t.foo("bar", variable)

		assert.has_error(function() verify(t.foo(wrong_variable)) end)
	end)

	it("return string", function()
		t:expect("foo", "returnz", "bar")

		assert.equal("returnz", t.foo("bar"))
	end)

	it("return table", function()
		local variable = {name = "var"}

		t:expect("foo", variable, "bar")

		assert.equal(variable, t.foo("bar"))
	end)

	it("returns for multiple", function()
		t:expect("foo", "return1", "bar")
		t:expect("foo", "return2", "baz")

		assert.equal("return1", t.foo("bar"))
		assert.equal("return2", t.foo("baz"))
	end)

	it("expect with no arguments", function()
		t:expect("foo", "returnz")

		assert.equal("returnz", t.foo())
	end)

	it("thenAnswer", function()
		when(t.foo("bar")).thenAnswer("baz")

		assert.equal("baz", t.foo("bar"))
	end)

	it("thenAnswer with no arg", function()
		when(t.foo()).thenAnswer("baz")

		assert.equal("baz", t.foo())
	end)

	it("thenAnswer cleans verify", function()
		when(t.foo()).thenAnswer("baz")

		assert.has_error(function() verify(t.foo()) end)
	end)

	it("thenAnswer with table arg", function()
		local variable = {name = "var"}

		when(t.foo()).thenAnswer(variable)

		assert.equal(variable, t.foo())
	end)

	it("thenAnswer return nil", function()
		when(t.foo()).thenAnswer(nil)

		assert.falsy(t.foo())
	end)

	it("when with anyType", function()
		when(t.foo(any())).thenAnswer("boo")

		assert.equal("boo", t.foo("baz"))
	end)

	it("when with two anyTypes", function()
		when(t.foo(any(), any())).thenAnswer("boo")

		assert.equal("boo", t.foo("baz", 5))
	end)

	it("when with anyType and real argument", function()
		when(t.foo(any(), 5)).thenAnswer("boo")

		assert.equal("boo", t.foo("baz", 5))
	end)

	it("when with self", function()
		when(t.foo(t)).thenAnswer("boo")

		assert.equal("boo", t.foo(t))
	end)

	it("getName return name", function()
		local namedMock = mockagne.getMock("mockname")

		assert.equal("mockname", namedMock:getName())
	end)

	it("getName return empty string when no name set", function()
		assert.equal("", t:getName())
	end)

	it("two mocks are independent", function()
		local u = mockagne.getMock()
		u.foo()
		assert.has_error(function() verify(t.foo()) end)
	end)

	it("thenAnswer with vararg return", function()
		when(t.foo("bar")).thenAnswer("foo", "bar", "baz")

		a, b, c = t.foo("bar")
		assert.equal("foo", a)
		assert.equal("bar", b)
		assert.equal("baz", c)
	end)

	--[[
	function test_thenAnswer_withSelf()
		when(t:foo("bar")).thenAnswer("baz")

		assert.equal("baz", t:foo("bar"))
	end

	]]--

end)