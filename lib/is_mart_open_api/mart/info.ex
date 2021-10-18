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

  def info!("homeplus", name) do
    document =
      IsMartOpenApi.Fetch.do_fetch_homeplus_html!(name)
      |> Floki.parse_document!()

    element =
      document
      |> Floki.find("li.clearfix")
      |> Enum.filter(fn find ->
        find
        |> Floki.find("span.name > a")
        |> Floki.text() == name
      end)

    time =
      element
      |> Floki.find(".time > span:nth-child(1)")
      |> Floki.text()
      |> String.split("~")

    now = Timex.now("Asia/Seoul")
    open_time = Timex.parse!("#{now |> Timex.format!("%Y%m%d", :strftime)} #{time |> Enum.at(0)} +0900", "%Y%m%d %H:%M %z", :strftime)
    close_time = if time |> Enum.at(1) |> String.slice(0..1) == "24" do
      Timex.parse!("#{now |> Timex.format!("%Y%m%d", :strftime)} 00:#{time |> Enum.at(1) |> String.slice(3..4)} +0900", "%Y%m%d %H:%M %z", :strftime)
      |> Date.add(1)
    else
      Timex.parse!("#{now |> Timex.format!("%Y%m%d", :strftime)} #{time |> Enum.at(1)} +0900", "%Y%m%d %H:%M %z", :strftime)
    end
    next_holiday = Timex.parse!(element |> Floki.find(".off") |> Floki.text(), "%Y-%m-%d", :strftime)

    state = cond do
      Timex.compare(now, next_holiday) == 0 ->
        :holiday_closed
      Timex.compare(now, open_time) == -1 ->
        :before_open
      Timex.compare(now, close_time) == 1 ->
        :after_closed
      true ->
        :open
    end

    %Information {
      name: element |> Floki.find("span.name > a") |> Floki.text(),
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
