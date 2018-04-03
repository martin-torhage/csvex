defmodule Csvex.Parse do
  @moduledoc """
  Module for parsing CSV.

  To reach higher performance, all the fold functions
  support selecting which columns to be returned from the underlying NIF. See
  CsvexParseTest for example.
  """

  @type options :: [option]
  @type option :: {:delimiter, :tab | :comma}
  @type row :: [binary]
  @type folder :: (row, any -> any)
  @type folder_maker :: folder | {:maker, (... -> {folder, capture})}
  @type capture :: [non_neg_integer] # List of column indexes where the left-most is 0.
  @type generator :: {(generator_state -> {binary, generator_state}), generator_state}
  @type generator_state :: any

  @doc """
  Parses one CSV string completely. It provides the simplest interface but
  likely not the best performance.
  """
  @spec string(binary, options) :: [row]
  def string(csv, options \\ []) do
    :csv.decode_binary(csv, default_options(options))
  end

  @doc """
  Folds over the rows in one CSV string.
  """
  @spec string_fold(binary, folder_maker, any, options) :: any
  def string_fold(csv, folder, acc, options \\ []) do
    :csv.decode_binary_fold(erlang_folder(folder), acc, csv, default_options(options))
  end

  @doc """
  Same as string_fold/4 but working on a gzipped CSV.
  """
  @spec gzip_fold(binary, folder_maker, any, options) :: any
  def gzip_fold(csv_gzip, folder, acc, options \\ []) do
    :csv.decode_gzip_fold(
      erlang_folder(folder),
      acc,
      csv_gzip,
      default_options(options)
    )
  end

  @doc """
  The generic parsing function which can handle all the use cases. The other
  functions are convenience function, which could be using fold/4 under the hood
  (but they map to the convenience functions available in the underlying `csv`
  lib instead).

  The csv_generator should generate sequential chunks of CSV. There is no requirement on
  the size of the chunks and they can include partial rows and values.
  """
  @spec fold(generator, folder_maker, any, options) :: any
  def fold(csv_generator, folder, acc, options \\ []) do
    :csv.decode_fold(erlang_folder(folder), acc, csv_generator, default_options(options))
  end

  # Elixir uses 0-based indexing (like it would be C), so we need to change it
  # to 1-based indexing (because Erlang is not C).
  defp erlang_folder({:maker, folder_maker}) do
    {:arity, arity} = :erlang.fun_info(folder_maker, :arity)
    {:maker, erlang_folder_maker(folder_maker, arity)}
  end

  defp erlang_folder(folder) do
    folder
  end

  # TODO: Replace this with a macro which doesn't have an arity limit.
  defp erlang_folder_maker(folder_maker, 0) do
    fn ->
      {folder, capture} = folder_maker.()
      {folder, erlang_indexing(capture)}
    end
  end

  defp erlang_folder_maker(folder_maker, 1) do
    fn a ->
      {folder, capture} = folder_maker.(a)
      {folder, erlang_indexing(capture)}
    end
  end

  defp erlang_folder_maker(folder_maker, 2) do
    fn a, b ->
      {folder, capture} = folder_maker.(a, b)
      {folder, erlang_indexing(capture)}
    end
  end

  defp erlang_folder_maker(_, _) do
    {:error, "Folder maker arity not supported"}
  end

  defp erlang_indexing(indexes) do
    for n <- indexes, do: n + 1
  end

  defp default_options(options) do
    [delimiter: :comma]
    |> Keyword.merge(options)
    |> Keyword.merge(return: :binary)
  end
end
