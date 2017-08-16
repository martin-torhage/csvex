defmodule Csvex do
  @moduledoc """
  Documentation for Csvex.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Csvex.hello
      :world

  """
  def parse_fold(csv_stream, acc, folder_maker, options \\ []) do
    :csv.decode_fold(
      {:maker, folder_maker},
      acc,
      stream_generator(csv_stream),
      options)
  end

  defp stream_generator(csv_stream) do
    generator = fn (stream) ->
      case Enum.take(stream, 1) do
        [csv] -> {csv, Stream.drop(stream, 1)}
        [] -> {"", :done}
      end
    end
    {generator, csv_stream}
  end

  def run() do
    csv_stream = File.stream!("/Users/kullervo/github/martin-torhage/csv/priv/benchtest.csv", [:raw])
    folder_maker = fn(_) ->
      folder = fn (_, acc) ->
        acc + 1
      end
      capture = [1, 3, 2]
      {folder, capture}
    end
    parse_fold(csv_stream, 0, folder_maker)
  end

end
