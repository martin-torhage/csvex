# Csvex

This is an Elixir wrapper for the high-performance NIF based Erlang CSV parser [github.com/martin-torhage/csv](https://github.com/martin-torhage/csv). The Erlang lib has been used in multiple production systems for several years.

## Performance

Csvex is in simple tests more than 6 times faster than the most popular Elixir CSV parser [csv](https://hex.pm/packages/csv). At the same time the total CPU usage for parsing the same file is 93% lower.

For even higher performance, you can select which columns to be returned, and therefor reduce the amount of data copied by the NIF into the process heap. See the docs for `Csvex.Parse` for more info.

## Todo
 - Add an Elixir Stream interface. It's expected to have lower performance.
 - Replace the clunky and limiting implementation of `erlang_folder/1` in `Csvex.Parse` with a macro.
 - Add support for generating CSV to make it more complete. `libcsv` supports it, so it could be implemented in the `csv` Erlang lib first.

## License
The MIT License (MIT). See LICENSE for details.
