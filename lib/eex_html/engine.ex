defmodule EExHTML.Engine do
  @moduledoc ~S"""
  An engine for templating HTML content.

  Interpolated values are HTML escaped,
  unless the term implements the `EExHTML.Safe` protocol.

  Values returned are `io_lists` for performance reasons.

  ## Examples

      iex> EEx.eval_string("foo <%= bar %>", [bar: "baz"], engine: EExHTML.Engine)
      ...> |> String.Chars.to_string
      "foo baz"

      iex> EEx.eval_string("foo <%= bar %>", [bar: "<script>"], engine: EExHTML.Engine)
      ...> |> String.Chars.to_string
      "foo &lt;script&gt;"

      iex> EEx.eval_string("foo <%= bar %>", [bar: EExHTML.raw("<script>")], engine: EExHTML.Engine)
      ...> |> String.Chars.to_string
      "foo <script>"

      iex> EEx.eval_string("foo <%= @bar %>", [assigns: %{bar: "<script>"}], engine: EExHTML.Engine)
      ...> |> String.Chars.to_string
      "foo &lt;script&gt;"

      iex> EEx.eval_string("<%= for _ <- 1..1 do %><p><%= bar %></p><% end %>", [bar: "<script>"], engine: EExHTML.Engine)
      ...> |> String.Chars.to_string
      "<p>&lt;script&gt;</p>"
  """
  require EEx.Engine

  def init(_options) do
    quote do: EExHTML.raw([])
  end

  def handle_begin(_previous) do
    quote do: EExHTML.raw([])
  end

  def handle_end(quoted) do
    quoted
  end

  def handle_text(buffer, text) do
    quote do
      EExHTML.raw([unquote(buffer).data | unquote(text)])
    end
  end

  def handle_body(quoted) do
    quoted
  end

  def handle_expr(buffer, "=", expr) do
    expr = Macro.prewalk(expr, &EEx.Engine.handle_assign/1)

    quote do
      EExHTML.raw([unquote(buffer).data, EExHTML.escape(unquote(expr)).data])
    end
  end

  def handle_expr(buffer, "", expr) do
    expr = Macro.prewalk(expr, &EEx.Engine.handle_assign/1)

    quote do
      tmp2 = unquote(buffer)
      unquote(expr)
      tmp2
    end
  end

  def handle_expr(state, marker, expr) do
    expr = Macro.prewalk(expr, &EEx.Engine.handle_assign/1)
    EEx.Engine.handle_expr(state, marker, expr)
  end
end
