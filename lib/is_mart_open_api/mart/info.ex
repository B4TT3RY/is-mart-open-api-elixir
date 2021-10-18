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

    today = Timex.today("Asia/Seoul")
    now = Timex.now("Asia/Seoul")
    open_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(json["OPEN_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")
    close_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(json["CLOSE_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")
    next_holiday = Timex.parse!(json["HOLIDAY_DAY1_YYYYMMDD"], "%Y%m%d", :strftime);

    state = cond do
      Timex.compare(today, next_holiday) == 0 ->
        :holiday_closed
      Timex.compare(now, open_time) == -1 ->
        :before_open
      Timex.compare(now, close_time) == 1 ->
        :after_closed
      true ->
        :open
    end

    %Information {
      name: json["NAME"] |> String.replace("이마트 ", ""),
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

    today = Timex.today("Asia/Seoul")
    now = Timex.now("Asia/Seoul")
    open_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(json["OPEN_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")
    close_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(json["CLOSE_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")
    next_holiday = Timex.parse!(json["HOLIDAY_DAY1_YYYYMMDD"], "%Y%m%d", :strftime);

    state = cond do
      Timex.compare(today, next_holiday) == 0 ->
        :holiday_closed
      Timex.compare(now, open_time) == -1 ->
        :before_open
      Timex.compare(now, close_time) == 1 ->
        :after_closed
      true ->
        :open
    end

    %Information {
      name: json["NAME"] |> String.replace("이마트 트레이더스 ", ""),
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

    today = Timex.today()
    now = Timex.now("Asia/Seoul")

    open_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(time |> Enum.at(0), "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")
    close_time = if time |> Enum.at(1) |> String.slice(0..1) == "24" do
      {Date.to_erl(today), Time.to_erl(Timex.parse!("00:#{time |> Enum.at(1) |> String.slice(3..4)}", "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")
      |> Date.add(1)
    else
      {Date.to_erl(today), Time.to_erl(Timex.parse!(time |> Enum.at(1), "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")
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
