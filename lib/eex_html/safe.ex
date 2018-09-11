defprotocol EExHTML.Safe do
  @moduledoc """
  This protocol is responsible for converting a structure to content that can be safely included in an HTML page.

  The only function required to be implemented is `to_iodata`, which does the conversion.

  If this protocol is not implemented for a term it falls back to `String.Chars.to_string/1`
  and handles HTML escaping.
  """
  @fallback_to_any true

  @enforce_keys [:data]
  defstruct @enforce_keys

  @doc """
  Converts a term to iodata.
  """
  def to_iodata(raw)
end

defimpl EExHTML.Safe, for: EExHTML.Safe do
  def to_iodata(%{data: data}), do: data
end

defimpl EExHTML.Safe, for: Any do
  def to_iodata(term), do: String.Chars.to_string(term) |> EExHTML.escape_to_iodata()
end

defimpl String.Chars, for: EExHTML.Safe do
  def to_string(%{data: data}) do
    IO.iodata_to_binary(data)
  end
end
