mockagne
========

Fully dynamic mocking for Lua.

## Usage
Start by requiring mockagne and creating some local function references for better readability:

    require "mockagne"
    
    local when = mockagne.when
    local any = mockagne.anyType
    local verify = mockagne.verify

Then just create a mock instance for you:

	t = mockagne.getMock()

Then you invoke anything on the mock instance. Like:

    t.foo()

Later you can verify that function foo() was really called with:

    verify(t.foo())

Same works with parameters:

    t.foo("bar")
    verify(t.foo("bar"))

If you want call to `t.foo()` return a value, you can teach the mock with:

    when(t.foo("bar")).thenAnswer("baz")
    print(t.foo("bar"))   -- this will print "baz"

For more examples, refer to `test.lua` that comes with mockagne and is used to unit test it.

