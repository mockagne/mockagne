--- Mockagne - Lua Mock Library
-- https://github.com/PunchWolf/mockagne
--
-- @copyright PunchWolf
-- @author Janne Sinivirta
-- @author Marko Pukari

package.path = package.path .. ";../lunatest/?.lua"


require "mockagne"
require "lunatest"

local t = nil
local when = mockagne.when
local any = mockagne.anyType
local verify = mockagne.verify

function setup()
	t = mockagne.getMock()
end

function test_no_argument_function()
	local returns = t.foo()

	verify(t.foo())
	assert_equal(nil, returns)
end

function test_no_invocation()
	-- no call made to t

	assert_error(function() verify(t.foo()) end)
end

function test_two_no_argument_calls()
	t.foo()
	t.bar()

	verify(t.bar())
	verify(t.foo())
end

function test_single_argument_function()
	t.foo("bar")
	verify(t.foo("bar"))
end

function test_single_argument_passed_to_function_is_self()
	t.foo(t)

	verify(t.foo(t))
end

function test_double_argument_function()
	t.foo("bar", "baz")

	verify(t.foo("bar", "baz"))
end


function test_single_table_argument_function()
	local variable = {name = "var"}

	t.foo(variable)

	verify(t.foo(variable))
end

function test_empty_anyType_with_one_parameter()
	local variable = {name = "var"}

	t.foo(variable)

	verify(t.foo(any()))
end

function test_empty_anyType_with_not_enough_one_parameter()
	local variable = {name = "var"}

	t.foo(variable, "bar")

	assert_error(function() verify(t.foo(any())) end)
end

function test_empty_anyType_with_all_parameters()
	local variable = {name = "var"}

	t.foo(variable, "bar")

	verify(t.foo(any(), "bar"))
end

function test_multiple_anyType_parameters()
	t.foo("bar", "baz")

	t:verify("foo", any(), any())
end

function test_empty_anyType_with_no_called_parameters()
	t.foo()

	assert_error(function() assert_error(verify(t.foo(any()))) end)
end

function test_typed_anyType_with_one_parameter()
	local variable = {name = "var"}

	t.foo(variable)

	verify(t.foo(any({})))
end

function test_typed_anyType_with_one_non_type_matching_parameter()
	local variable = {name = "var"}

	t.foo("bar")

	assert_error(function() verify(t.foo(any({}))) end)
end

function test_typed_anyType_with_two_matching_parameter()
	local variable = {name = "var"}

	t.foo(variable, "bar")

	verify(t.foo(variable, any("")))
end

function test_typed_anyType_with_no_called_parameters()
	t.foo()

	assert_error(function() verify(t.foo(any({}))) end)
end

function test_wrong_argument()
	t.foo("bar")

	assert_error(function() verify(t.foo("dork")) end)
end

function test_wrong_function_name()
	t.foo("bar")

	assert_error(function() verify(t.dork("bar")) end)
end

function test_wrong_table_argument()
	local variable = {name = "var"}
	local wrong_variable = {name = "var"}

	t.foo("bar", variable)

	assert_error(function() verify(t.foo(wrong_variable)) end)
end


function test_return_string()
	t:expect("foo", "returnz", "bar")

	assert_equal("returnz", t.foo("bar"))
end

function test_return_table()
	local variable = {name = "var"}

	t:expect("foo", variable, "bar")

	assert_equal(variable, t.foo("bar"))
end

function test_returns_for_multiple()
	t:expect("foo", "return1", "bar")
	t:expect("foo", "return2", "baz")

	assert_equal("return1", t.foo("bar"))
	assert_equal("return2", t.foo("baz"))
end

function test_expect_with_no_arguments()
	t:expect("foo", "returnz")

	assert_equal("returnz", t.foo())
end

function test_thenAnswer()
	when(t.foo("bar")).thenAnswer("baz")

	assert_equal("baz", t.foo("bar"))
end

function test_thenAnswer_no_arg()
	when(t.foo()).thenAnswer("baz")

	assert_equal("baz", t.foo())
end

function test_thenAnswer_cleans_verify()
	when(t.foo()).thenAnswer("baz")

	assert_error(function() verify(t.foo()) end)
end

function test_thenAnswer_with_table_arg()
	local variable = {name = "var"}

	when(t.foo()).thenAnswer(variable)

	assert_equal(variable, t.foo())
end

function test_thenAnswer_returns_nil()
	when(t.foo()).thenAnswer(nil)

	assert_equal(nil, t.foo())
end

function test_when_with_anytype()
	when(t.foo(any())).thenAnswer("boo")

	assert_equal("boo", t.foo("baz"))
end

function test_when_with_double_anytype()
	when(t.foo(any(), any())).thenAnswer("boo")

	assert_equal("boo", t.foo("baz", 5))
end

function test_when_with_anytype_and_real_arg()
	when(t.foo(any(), 5)).thenAnswer("boo")

	assert_equal("boo", t.foo("baz", 5))
end

function test_when_with_self()
	when(t.foo(t)).thenAnswer("boo")

	assert_equal("boo", t.foo(t))
end

function test_getName_returns_name()
	local namedMock = mockagne.getMock("mockname")

	assert_equal("mockname", namedMock:getName())
end

function test_getName_returns_empty_string_when_no_name_exists()
	assert_equal("", t:getName())
end

function test_two_mocks_are_independent()
	local u = mockagne.getMock()
	u.foo()
	assert_error(function() verify(t.foo()) end)
end

function test_thenAnswer_with_vararg_return()
	when(t.foo("bar")).thenAnswer("foo", "bar", "baz")

	a, b, c = t.foo("bar")
	assert_equal("foo", a)
	assert_equal("bar", b)
	assert_equal("baz", c)
end

--[[
function test_thenAnswer_withSelf()
	when(t:foo("bar")).thenAnswer("baz")

	assert_equal("baz", t:foo("bar"))
end

]]--

lunatest.run()