# mockagne - Mocking Framework for Lua

`mockagne` is a fully dynamic mocking framework that is designed to be a Lua variant of the famous Java framework [mockito](https://site.mockito.org/).

## In a Nutshell

```lua
local mockagne = require("mockagne")
local mock = mockagne.getMock()
mockagne.when(mock.say(mockagne.any())).thenAnswer("Hello world")
-- ...
mock.ask("What's your name?")
mockagne.verify(mock.ask("What's your name?"))
```

## Information for Users

* [User Guide](doc/user_guide/user_guide.md)

## Dependencies

### Runtime Dependencies

`mockagne` is a single-file pure-Lua module with no other runtime dependencies than Lua 5.1 or later.

### Test Dependencies

| Dependency                               | Purpose                                                | License                       |
|------------------------------------------|--------------------------------------------------------|-------------------------------|
| [busted][busted]                         | Unit testing framework                                 | MIT License        |

[busted]: https://github.com/Olivine-Labs/busted

### License

Lua is Open Source, distributed under the terms of the [MIT license](License).

Copyright (c) 2013 Punch Wolf Game Studios.
Copyright (c) 2020 [Exasol](https://www.exasol.com).
