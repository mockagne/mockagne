package = "Mockagne"
version = "1.0-2"

source = {
   url = "git://github.com/mockagne/mockagne",
   tag = "1.0.2"
}

description = {
   summary = "Fully dynamic mocking for Lua.",
   detailed = [[
      Fully dynamic mocking for Lua. Create mock objects with ease, 
      teach them to return values and verify their invocations.
   ]],
   homepage = "https://github.com/mockagne/mockagne",
   license = "MIT"
}

dependencies = { "lua >= 5.1, <= 5.4" }
build = {
   type = "builtin",
   modules = {mockagne = "src/mockagne.lua"},
   copy_directories = { "doc", "test" }
}