defmodule EExHTML do
  @moduledoc ~S"""
  Extension to Embedded Elixir (EEx), part of the standard library,
  that allows content to be safely embedded into HTML.

      iex> title = "EEx Rocks!"
      iex> content = ~E"<h1><%= title %></h1>"
      %EExHTML.Safe{data: [[[[] | "<h1>"], "EEx Rocks!"] | "</h1>"]}
      iex> "#{content}"
      "<h1>EEx Rocks!</h1>"

      iex> title = "<script>"
      iex> content = ~E"<h1><%= title %></h1>"
      %EExHTML.Safe{data: [[[[] | "<h1>"], [[[] | "&lt;"], "script" | "&gt;"]] | "</h1>"]}
      iex> "#{content}"
      "<h1>&lt;script&gt;</h1>"

  ## Safe HTML

  #### Escaping

  The main responsibility of this library is to ensure safety when embedding content into HTML pages.
  Any term that implements the `String.Chars` protocol can be embedded but will be assumed unsafe.

      iex> title = :"<script>"
      iex> content = ~E"<h1><%= title %></h1>"
      %EExHTML.Safe{data: [[[[] | "<h1>"], [[[] | "&lt;"], "script" | "&gt;"]] | "</h1>"]}
      iex> "#{content}"
      "<h1>&lt;script&gt;</h1>"


  #### JavaScript

  >  Including untrusted data inside any other JavaScript context is quite dangerous, as it is extremely easy to switch into an execution context with characters including (but not limited to) semi-colon, equals, space, plus, and many more, so use with caution.
  [XSS Prevention Cheat Sheet](https://www.owasp.org/index.php/XSS_(Cross_Site_Scripting)_Prevention_Cheat_Sheet#RULE_.233_-_JavaScript_Escape_Before_Inserting_Untrusted_Data_into_JavaScript_Data_Values)

  **DONT DO THIS**

        ~E\"\"\"
        <script type="text/javascript">
          console.log('Hello, ' + <%= name %>)
        </script>
        \"\"\"

  Use `javascript_variables/1` for injecting variables into any JavaScript environment.

  **DO THIS**

        ~E\"\"\"
        <%= javascript_variables name: "Cynthia" %>
        <script type="text/javascript">
          console.log('Hello, ' + name)
        </script>
        \"\"\"

  #### Raw content

  <script type="text/javascript">
    console.log('Hello, ' + <%= name %>)
  </script>

  **Data supplied by the user or other external source should never be considered safe.
  The assumption that user data is safe is the source of [Cross-Site Scripting(XSS)](https://www.owasp.org/index.php/Cross-site_Scripting_(XSS)) attacks.**

  There some cases where data is safe and you want to use the raw content in a template.

      iex> title = "<script>"
      iex> content = ~E"<h1><%= raw title %></h1>"
      %EExHTML.Safe{data: [[[[] | "<h1>"], "<script>"] | "</h1>"]}
      iex> "#{content}"
      "<h1><script></h1>"

  Note content produced from a template is automatically considered safe

      iex> title = "<script>"
      iex> header = ~E"<h1><%= title %></h1>"
      iex> page = ~E"<header><%= header %></header>"
      iex> "#{page}"
      "<header><h1>&lt;script&gt;</h1></header>"

  #### EExHTML.Safe

  Any struct can implement the `EExHTML.Safe` protocol for custom behaviour when it is used in templates.

  ## Engine

  The `EExHTML.Engine` implements the `EEx.Engine` behaviour and can be used in `EEx` functions.

      iex> EEx.eval_string("<%= title %>", [title: "<script>"], engine: EExHTML.Engine).data
      [[], [[[] | "&lt;"], "script" | "&gt;"]]
  """
  alias __MODULE__.Safe

  @doc """
  Escape the HTML content derived from the given term.

  The content is returned wrapped in an `EExHTML.Safe` struct so it is not reescaped by templates etc.
  """
  # Short circuit escaping the content, if already wrapped as safe.
  def escape(content = %Safe{}) do
    content
  end

  def escape(term) do
    iodata = Safe.to_iodata(term)
    %Safe{data: iodata}
  end

  @doc """
  Mark some content as safe so that it can be used in a template.

  Will check that content is an iolist or implements `String.Chars` protocol.
  """
  def raw(content = %Safe{}) do
    content
  end

  def raw(iodata) when is_binary(iodata) do
    %Safe{data: iodata}
  end

  def raw(iodata) when is_list(iodata) do
    _ = :erlang.iolist_size(iodata)
    %Safe{data: iodata}
  catch
    :error, :badarg ->
      raise ArgumentError, "Invaild iodata, contains invalid terms such as integers or atoms."
  end

  def raw(term) do
    binary = String.Chars.to_string(term)
    %Safe{data: binary}
  end

  # NOTE uppercase sigil ignores `#{}`
  @doc """
  This module adds `~E` sigil for safe HTML escaped content.
  """
  defmacro sigil_E({:<<>>, [line: line], [template]}, []) do
    ast = EEx.compile_string(template, engine: EExHTML.Engine, line: line + 1)

    quote line: line do
      EExHTML.raw(unquote(ast))
    end
  end

  @doc ~S"""
  Escapes the given HTML to string.

      iex> EExHTML.escape_to_binary("foo")
      "foo"

      iex> EExHTML.escape_to_binary("<foo>")
      "&lt;foo&gt;"

      iex> EExHTML.escape_to_binary("quotes: \" & \'")
      "quotes: &quot; &amp; &#39;"

      iex> escape_to_binary("<script>")
      "&lt;script&gt;"

      iex> escape_to_binary("html&company")
      "html&amp;company"

      iex> escape_to_binary("\"quoted\"")
      "&quot;quoted&quot;"

      iex> escape_to_binary("html's test")
      "html&#39;s test"
  """
  @spec escape_to_binary(String.t()) :: String.t()
  def escape_to_binary(data) when is_binary(data) do
    IO.iodata_to_binary(to_iodata(data, 0, data, []))
  end

  @doc ~S"""
  Escapes the given HTML to iodata.

      iex> EExHTML.escape_to_iodata("foo")
      "foo"

      iex> EExHTML.escape_to_iodata("<foo>")
      [[[] | "&lt;"], "foo" | "&gt;"]

      iex> EExHTML.escape_to_iodata("quotes: \" & \'")
      [[[[], "quotes: " | "&quot;"], " " | "&amp;"], " " | "&#39;"]
  """
  @spec escape_to_iodata(String.t()) :: iodata
  def escape_to_iodata(data) when is_binary(data) do
    to_iodata(data, 0, data, [])
  end

  escapes = [
    {?<, "&lt;"},
    {?>, "&gt;"},
    {?&, "&amp;"},
    {?", "&quot;"},
    {?', "&#39;"}
  ]

  for {match, insert} <- escapes do
    defp to_iodata(<<unquote(match), rest::bits>>, skip, original, acc) do
      to_iodata(rest, skip + 1, original, [acc | unquote(insert)])
    end
  end

  defp to_iodata(<<_char, rest::bits>>, skip, original, acc) do
    to_iodata(rest, skip, original, acc, 1)
  end

  defp to_iodata(<<>>, _skip, _original, acc) do
    acc
  end

  for {match, insert} <- escapes do
    defp to_iodata(<<unquote(match), rest::bits>>, skip, original, acc, len) do
      part = binary_part(original, skip, len)
      to_iodata(rest, skip + len + 1, original, [acc, part | unquote(insert)])
    end
  end

  defp to_iodata(<<_char, rest::bits>>, skip, original, acc, len) do
    to_iodata(rest, skip, original, acc, len + 1)
  end

  defp to_iodata(<<>>, 0, original, _acc, _len) do
    original
  end

  defp to_iodata(<<>>, skip, original, acc, len) do
    [acc | binary_part(original, skip, len)]
  end

  @doc """
  Safety inject server variables into a pages JavaScript.
  """
  case Code.ensure_loaded(Jason) do
    {:module, _} ->
      def javascript_variables(variables) do
        variables = Enum.into(variables, %{})

        json = Jason.encode!(variables)
        # NOTE returned io_data contains integer values, which ar valid io_data.
        # IO.iodata_to_binary([34]) == "\""
        # Because EExHTML.Safe makes use of String.Chars it is not possible to know how `[34]` should be printed.
        # "34" or "\"", for this reason we can't use iodata encoding.
        # json = Jason.encode_to_iodata!(variables)

        key_string =
          variables
          |> Map.keys()
          |> Enum.map(&Atom.to_string/1)
          |> Enum.join(", ")

        ~E"""
        <div style='display:none;'><%= json %></div>
        <script>const{<%= key_string %>}=JSON.parse(document.currentScript.previousElementSibling.textContent)</script>
        """
      end

    {:error, :nofile} ->
      def javascript_variables(_variables) do
        raise "`javascript_variables/1` requires the Jason encoder, add `{:jason, \"~> 1.0.0\"}` to `mix.exs`"
      end
  end
end
