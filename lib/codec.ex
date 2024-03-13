defmodule Calibex.Codec do
  @moduledoc "Module containing format and parse rules for ical terms"

  def encode(props), do: encode_value(props) <> "\r\n"
  # encode multiple kwlist with begin/end
  def encode_value({k, [[{_k, _v} | _] | _] = vals}) do
    vals
    |> Enum.map_join(
      "\r\n",
      &"BEGIN:#{encode_key(k)}\r\n#{encode_value(&1)}\r\nEND:#{encode_key(k)}"
    )
  end

  # encode kwlist with limited length lines
  def encode_value([{_k, _v} | _] = props) do
    props |> Enum.map_join("\r\n", &(&1 |> encode_value() |> encode_line()))
  end

  # encode value with properties
  def encode_value({k, [{_k, _v} | _] = v}) do
    "#{encode_key(k)};#{v |> Keyword.delete(:value) |> Enum.map_join(";", fn {pk, pv} -> "#{encode_key(pk)}=#{encode_value(pv)}" end)}:#{encode_value(v[:value])}"
  end

  # encode standard key value
  def encode_value({k, v}), do: "#{encode_key(k)}:#{encode_value(v)}"

  def encode_value(%DateTime{} = dt),
    do: %{dt | microsecond: {0, 0}} |> Timex.to_datetime("UTC") |> Timex.format!("{ISO:Basic:Z}")

  def encode_value(atom) when is_atom(atom), do: atom |> to_string() |> String.upcase()
  def encode_value(other), do: other

  def encode_key(k) do
    k |> to_string() |> String.replace("_", "-") |> String.upcase()
  end

  # DO NOT encode block values
  def encode_line("BEGIN:" <> _ = bin), do: bin

  def encode_line(bin) do
    if String.length(bin) <= 75 do
      bin
    else
      bin = String.replace(bin, ~r/[\r|\n]/, "\\n")
      {str_left, str_right} = String.split_at(bin, 75)
      str_left <> "\r\n " <> encode_line(str_right)
    end
  end

  def decode(bin), do: bin |> decode_lines |> decode_blocks

  # split by unfolded line
  def decode_lines(bin) do
    bin
    |> String.splitter(["\r\n", "\n"])
    |> Enum.flat_map_reduce(nil, fn
      " " <> rest, acc -> {[], acc <> rest}
      line, prevline -> {(prevline && [String.replace(prevline, "\\n", "\n")]) || [], line}
    end)
    |> elem(0)
  end

  def decode_blocks([]), do: []
  # decode each block as a list
  def decode_blocks(["BEGIN:" <> binkey | rest]) do
    {props, [_ | lines_rest]} = Enum.split_while(rest, &(!match?("END:" <> ^binkey, &1)))
    key = decode_key(binkey)
    # accumulate block of same keys
    case decode_blocks(lines_rest) do
      [{^key, elems} | props_rest] -> [{key, [decode_blocks(props) | elems]} | props_rest]
      props_rest -> [{key, [decode_blocks(props)]} | props_rest]
    end
  end

  # recursive decoding if no BEGIN/END block
  def decode_blocks([prop | rest]), do: [decode_prop(prop) | decode_blocks(rest)]
  # decode key,params and value for each prop
  def decode_prop(prop) do
    [keyprops, val] = String.split(prop, ":", parts: 2)

    case String.split(keyprops, ";") do
      [key] ->
        {decode_key(key), val}

      [key | props] ->
        props =
          props
          |> Enum.map(fn prop ->
            [k, v] = String.split(prop, "=")
            {decode_key(k), v}
          end)

        {decode_key(key), [{:value, val} | props]}
    end
  end

  def decode_key(bin),
    do: bin |> String.replace("-", "_") |> String.downcase() |> String.to_atom()
end
