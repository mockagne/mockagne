# User Guide &mdash; `mockagne`

## Introduction

_Mockagne_ was originally written by Janne Sinivirta and Marko Pukari. It was created to help with testing of our mobile games written in Lua. It is now maintained by Sebastian Bär.

_Mockagne_ name is a cross between _mock_ and _champagne_, like it's Java big brother _mockito_. We are great fans of _mockito_ and mockagne is heavily based on _mockito_'s DSL.

## Using `mockagne`

### Creating and using mocks
Start by requiring mockagne and creating some local function references for better readability:

```lua
local mockagne = require "mockagne"

local when = mockagne.when
local any = mockagne.any
local verify = mockagne.verify
```

Then just create a mock instance for you:

```lua
t = mockagne.getMock()
```

Then you can invoke anything on the mock instance. Like:

```lua
t.foo()
```

### Verifying calls to mocks
After your test has executed, you might be interested if a specific function on a mock was called. For example, to check if function `foo()` was call, you would simply say:

```lua
verify(t.foo())
```

Same works with parameters:

```lua
t.foo("bar")
verify(t.foo("bar"))
```

### Returning values from mocks
If you want a call to `t.foo()` to return a value, you can teach the mock with:

```lua
when(t.foo("bar")).thenAnswer("baz")
print(t.foo("bar"))   -- this will print "baz"
```

Otherwise calls to mock methods will return `nil`.

### More examples
For more examples, refer to [`mockagne_spec.lua`](../../test/mockagne_spec.lua) that comes with. It contains all unit tests used to exercise mockagnes all features.

## Installation

Easiest way to install `mockagne` is through `luarocks`. Just run

    luarocks install mockagne

For manual installation, just add `mockagne.lua` to your `package.path`.
