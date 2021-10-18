defmodule IsMartOpenApi.Info do
  defmodule Information do
    @derive Jason.Encoder
    defstruct [:name, :state, :open_time, :close_time, :next_holiday]
  end

  @spec info!(mart :: String.t(), name :: String.t()) :: Information | nil
  def info!("emart", name) do
    json = IsMartOpenApi.Fetch.do_fetch_emart_json!("EM", name)
    |> Enum.filter(fn element -> element["NAME"] == "이마트 " <> name end)
    |> Enum.at(0)

    now = Timex.now("Asia/Seoul")
    open_time = Timex.parse!(json["OPEN_SHOPPING_TIME"], "%H:%M", :strftime);
    close_time = Timex.parse!(json["CLOSE_SHOPPING_TIME"], "%H:%M", :strftime);
    next_holiday = Timex.parse!(json["HOLIDAY_DAY1_YYYYMMDD"], "%Y%m%d", :strftime);

    state = cond do
      Date.compare(now, next_holiday) == :eq ->
        :holiday_closed
      Time.compare(now, open_time) == :lt ->
        :before_open
      Time.compare(now, close_time) == :gt ->
        :after_closed
      true ->
        :open
    end

    %Information {
      name: json["NAME"],
      state: state,
      open_time: open_time |> Timex.format!("%H:%M:%S", :strftime),
      close_time: close_time |> Timex.format!("%H:%M:%S", :strftime),
      next_holiday: next_holiday |> Timex.format!("%Y-%m-%d", :strftime),
    }
  end

  def info!("traders", name) do
    json = IsMartOpenApi.Fetch.do_fetch_emart_json!("TR", name)
    |> Enum.filter(fn element -> element["NAME"] == "이마트 트레이더스 " <> name end)
    |> Enum.at(0)

    now = Timex.now("Asia/Seoul")
    open_time = Timex.parse!(json["OPEN_SHOPPING_TIME"], "%H:%M", :strftime);
    close_time = Timex.parse!(json["CLOSE_SHOPPING_TIME"], "%H:%M", :strftime);
    next_holiday = Timex.parse!(json["HOLIDAY_DAY1_YYYYMMDD"], "%Y%m%d", :strftime);

    state = cond do
      Date.compare(now, next_holiday) == :eq ->
        :holiday_closed
      Time.compare(now, open_time) == :lt ->
        :before_open
      Time.compare(now, close_time) == :gt ->
        :after_closed
      true ->
        :open
    end

    %Information {
      name: json["NAME"],
      state: state,
      open_time: open_time |> Timex.format!("%H:%M:%S", :strftime),
      close_time: close_time |> Timex.format!("%H:%M:%S", :strftime),
      next_holiday: next_holiday |> Timex.format!("%Y-%m-%d", :strftime),
    }
  end

  def info!(_, _) do
    nil
  end
end
