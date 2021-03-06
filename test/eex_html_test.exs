defmodule EExHTMLTest do
  use ExUnit.Case, async: true
  import EExHTML
  doctest EExHTML

  test "raw accepts binary" do
    assert "Hello, World!" == "#{raw("Hello, World!")}"
  end

  test "raw accepts iolist" do
    assert "Hello, World!" == "#{raw(["Hello, ", ["World!"]])}"
  end

  test "raw accepts any term that implements String.Chars" do
    assert "Hello, World!" == "#{raw(:"Hello, World!")}"
    assert "125" == "#{raw(125)}"
  end

  test "raises ArgumentError when not an iolist" do
    assert_raise(
      ArgumentError,
      "Invaild iodata, contains invalid terms such as integers or atoms.",
      fn ->
        raw([:foo])
      end
    )
  end
end
