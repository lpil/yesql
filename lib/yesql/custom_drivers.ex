defmodule CustomDrivers do
  @moduledoc """
    Specify standard drivers Postgrex and Ecto but
    load further driver modules according to config.
    In config, specify :yesql :supported_drivers as list:
    e.g.:

    config :yesql,
    custom_yesql_drivers: [Mssqlex]
  """

  Module.register_attribute(Yesql, :supported_drivers, accumulate: true)

  defmacro __using__(_opts) do

    case Application.fetch_env(:yesql, :custom_yesql_drivers) do
      :error -> :ok
      {:ok, driver_list} -> IO.inspect driver_list
                            for driver <- driver_list do
                              IO.puts "Adding driver to supported driver: #{driver}"
                              Module.put_attribute(Yesql, :supported_drivers, driver)
                            end
    end

    Module.put_attribute(Yesql, :supported_drivers, Postgrex)
    Module.put_attribute(Yesql, :supported_drivers, Ecto)
  end

end
