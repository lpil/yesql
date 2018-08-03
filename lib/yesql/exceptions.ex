defmodule Yesql.MissingParam do
  @moduledoc false
  defexception [:message]

  def exception(param) do
    msg = """
    Required parameter `:#{param}` not given
    """

    %__MODULE__{message: msg}
  end
end

defmodule Yesql.UnknownDriver do
  @moduledoc false
  defexception [:message]

  def exception(driver) do
    msg = """
    Unknown database driver #{driver}
    """

    %__MODULE__{message: msg}
  end
end

defmodule Yesql.NoDriver do
  @moduledoc false
  defexception [:message]

  def exception(fun_name) do
    msg = """
    No driver set for Yesql query #{fun_name}

    Please set the `:driver` option in either the `defquery/2`
    options or the `use Yesql` options
    """

    %__MODULE__{message: msg}
  end
end
