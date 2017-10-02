defmodule Utils.DateUtils do

  @doc ~S"""
  Parses string with date into date obejct. Accepts dates in formats possible in http message headers. If date is not parsable current date is returned.

  ## Examples

      iex> Utils.DateUtils.parse_date("Fri, 8 Dec 2017 23:59:59 GMT")
      #DateTime<2017-12-08 23:59:59Z>

      iex> Utils.DateUtils.parse_date("Friday, 8-Dec-17 23:59:59 GMT")
      #DateTime<2017-12-08 23:59:59Z>

      iex> Utils.DateUtils.parse_date("Fri Dec 8 23:59:59 2017")
      #DateTime<2017-12-08 23:59:59Z>

      iex> Utils.DateUtils.parse_date('Fri, 8 Dec 2017 23:59:59 GMT')
      #DateTime<2017-12-08 23:59:59Z>

      iex> Utils.DateUtils.parse_date('Friday, 8-Dec-17 23:59:59 GMT')
      #DateTime<2017-12-08 23:59:59Z>

      iex> Utils.DateUtils.parse_date('Fri Dec 8 23:59:59 2017')
      #DateTime<2017-12-08 23:59:59Z>
  """
  def parse_date(date) do
    date_str = date
               |> to_string
    case date_str |> Timex.parse("{RFC1123}") do
      {:ok, dt} -> 
        dt
      {:error, _} -> 
        case date_str |> Timex.parse("{ANSIC}") do
          {:ok, dt} ->
            dt
          {:error, _} -> 
            case date_str |> Timex.parse("{WDfull}, {D}-{Mshort}-{YY} {ISOtime} {Zname}") do 
              {:ok, dt} ->
                dt
              {:error, _} -> 
                Timex.now
            end
        end
    end |> Timex.to_datetime
  end

  def current_date do
    Timex.now("Europe/Warsaw")
    |> Timex.format!("{RFC1123}")
  end
end
