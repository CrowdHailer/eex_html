# EExHTML

**Extension to Embedded Elixir (EEx), that allows content to be safely embedded into HTML.**

[![Hex pm](http://img.shields.io/hexpm/v/eex_html.svg?style=flat)](https://hex.pm/packages/eex_html)
[![Build Status](https://secure.travis-ci.org/CrowdHailer/eex_html.svg?branch=master
"Build Status")](https://travis-ci.org/CrowdHailer/eex_html)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

- [Install from hex.pm](https://hex.pm/packages/eex_html)
- [Documentation available on hexdoc](https://hexdocs.pm/eex_html)

## Usage

```elixir
iex> title = "EEx Rocks!"
iex> content = ~E"<h1><%= title %></h1>"
iex> "#{content}"
"<h1>EEx Rocks!</h1>"

iex> title = "<script>"
iex> content = ~E"<h1><%= title %></h1>"
iex> "#{content}"
"<h1>&lt;script&gt;</h1>"
```

## Elixir language proposal

I would like to see this project as part of the Elixir language.
The reasons for this are explained in [this proposal](https://groups.google.com/forum/#!topic/elixir-lang-core/NC3TSaw19uk).
