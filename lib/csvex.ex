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

  def parse_file_fold(filename, acc, folder_maker, options \\ []) do
    :csv.decode_fold(
      {:maker, folder_maker},
      acc,
      file_generator(filename),
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

  defp file_generator(file) do
    {:ok, fp} = :file.open(file, [:read, :raw, :binary])
    generator = fn (fp) ->
      case :file.read(fp, 65536) do
        {:ok, chunk} ->
          {chunk, fp}
        :eof ->
          {"", :done}
      end
    end
    {generator, fp}
  end

  def run() do
    filename = "/Users/kullervo/github/martin-torhage/csv/priv/benchtest.csv"
    csv_stream = File.stream!(filename, [:raw])
    folder_maker = fn(_) ->
      folder = fn (_, acc) ->
        acc + 1
      end
      capture = [1, 3, 2]
      {folder, capture}
    end
    parse_file_fold(filename, 0, folder_maker)
  end

end
