defmodule CsvexParseTest do
  use ExUnit.Case
  alias Csvex.Parse

  doctest Parse

  @data [
    ["header1colA", "header1colB", "header1colC"],
    ["header2colA", "header2colB", "header2colC"],
    ["body1colA", "body1colB", "body1colC"],
    ["body2colA", "body2colB", "body2colC"]
  ]

  @csv @data
       |> Enum.map(&Enum.join(&1, ","))
       |> Enum.join("\n")

  test "parse csv string" do
    csv = """
    row1colA\trow1colB
    row2colA\trow2colB
    """

    options = [delimiter: :tab]

    assert Parse.string(csv, options) == [
             ["row1colA", "row1colB"],
             ["row2colA", "row2colB"]
           ]
  end

  test "parse only selected columns" do
    folder =
      {:maker,
       fn row1, row2 ->
         assert ["header1colA", "header1colB", "header1colC"] == row1
         assert ["header2colA", "header2colB", "header2colC"] == row2
         {&folder/2, [1, 0]}
       end}

    assert Parse.string_fold(@csv, folder, []) == [
             ["body1colB", "body1colA"],
             ["body2colB", "body2colA"]
           ]
  end

  test "parse gzipped CSV" do
    assert Parse.gzip_fold(gzip(@csv), &folder/2, []) == @data
  end

  test "parse with generators" do
    assert Parse.fold(generator(chunks(@csv)), &folder/2, []) == @data
  end

  defp folder(row, acc), do: acc ++ [row]

  defp chunks(string) do
    Enum.reverse(chunks(string, []))
  end

  defp chunks("", acc), do: acc

  defp chunks(<<char>> <> rest, acc) do
    new_acc = [<<char>> | acc]
    chunks(rest, new_acc)
  end

  defp generator(chunks) do
    {
      fn
        [chunk] ->
          {chunk, :done}

        [chunk | rest] ->
          {chunk, rest}
      end,
      chunks
    }
  end

  defp gzip(string) do
    :zlib.gzip(string)
  end
end
