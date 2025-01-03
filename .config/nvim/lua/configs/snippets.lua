local ls = require "luasnip"
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local parse = require("luasnip.util.parser").parse_snippet

--- Golang Snippets
ls.add_snippets("go", {
  s({ trig = "iferr", name = "if error", desc = "" }, {
    t { "if err != nil {", "" },
    t "  ",
    i(1),
    t { "", "}" },
  }),

  parse(
    { trig = "ifel", name = "If err, Log Fatal", desc = "" },
    [[
  if err != nil {
    log.Fatal(err)
  }
    ]]
  ),

  s({ trig = "ifew", name = "If err, wrap", desc = "" }, {
    t "if err != nil {",
    t { "", '  return fmt.Errorf("failed to ' },
    i(1, "message"),
    t ': %w", err)',
    t { "", "}" },
  }),
})
