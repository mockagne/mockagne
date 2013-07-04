mockagne
========

Fully dynamic mocking for Lua.

## Usage
### Creating and using mocks
Start by requiring mockagne and creating some local function references for better readability:

    local mockagne = require "mockagne"
    
    local when = mockagne.when
    local any = mockagne.any
    local verify = mockagne.verify

Then just create a mock instance for you:

	t = mockagne.getMock()

Then you can invoke anything on the mock instance. Like:

    t.foo()

### Verifying calls to mocks
After your test has executed, you might be interested if a specific function on a mock was called. For example, to check if function `foo()` was call, you would simply say:

    verify(t.foo())

Same works with parameters:

    t.foo("bar")
    verify(t.foo("bar"))

### Returning values from mocks
If you want a call to `t.foo()` to return a value, you can teach the mock with:

    when(t.foo("bar")).thenAnswer("baz")
    print(t.foo("bar"))   -- this will print "baz"

Otherwise calls to mock methods will return `nil`.

### Find out more
For more examples, refer to `test.lua` that comes with mockagne and is used to unit test it.

