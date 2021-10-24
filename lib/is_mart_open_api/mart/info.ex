defmodule IsMartOpenApi.Info do
  defmodule Information do
    @derive Jason.Encoder
    defstruct [:name, :state, :open_time, :close_time, :next_holiday]
  end

  @spec info!(mart :: String.t(), name :: String.t()) :: Information | nil
  def info!("emart", name) do
    json =
      IsMartOpenApi.Fetch.fetch_emart_json!("EM", name)
      |> Enum.filter(fn element -> element["NAME"] == "이마트 " <> name end)
      |> Enum.at(0)

    today = Timex.today("Asia/Seoul")
    now = Timex.now("Asia/Seoul")

    open_time =
      {Date.to_erl(today),
       Time.to_erl(Timex.parse!(json["OPEN_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")

    close_time =
      {Date.to_erl(today),
       Time.to_erl(Timex.parse!(json["CLOSE_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")

    next_holiday = Timex.parse!(json["HOLIDAY_DAY1_YYYYMMDD"], "%Y%m%d", :strftime)

    state =
      cond do
        Timex.compare(today, next_holiday) == 0 ->
          :holiday_closed

        Timex.compare(now, open_time) == -1 ->
          :before_open

        Timex.compare(now, close_time) == 1 ->
          :after_closed

        true ->
          :open
      end

    %Information{
      name: json["NAME"] |> String.replace("이마트 ", ""),
      state: state,
      open_time: open_time |> Timex.format!("%H:%M:%S", :strftime),
      close_time: close_time |> Timex.format!("%H:%M:%S", :strftime),
      next_holiday: next_holiday |> Timex.format!("%Y-%m-%d", :strftime)
    }
  end

  def info!("traders", name) do
    json =
      IsMartOpenApi.Fetch.fetch_emart_json!("TR", name)
      |> Enum.filter(fn element -> element["NAME"] == "이마트 트레이더스 " <> name end)
      |> Enum.at(0)

    today = Timex.today("Asia/Seoul")
    now = Timex.now("Asia/Seoul")

    open_time =
      {Date.to_erl(today),
       Time.to_erl(Timex.parse!(json["OPEN_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")

    close_time =
      {Date.to_erl(today),
       Time.to_erl(Timex.parse!(json["CLOSE_SHOPPING_TIME"], "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")

    next_holiday = Timex.parse!(json["HOLIDAY_DAY1_YYYYMMDD"], "%Y%m%d", :strftime)

    state =
      cond do
        Timex.compare(today, next_holiday) == 0 ->
          :holiday_closed

        Timex.compare(now, open_time) == -1 ->
          :before_open

        Timex.compare(now, close_time) == 1 ->
          :after_closed

        true ->
          :open
      end

    %Information{
      name: json["NAME"] |> String.replace("이마트 트레이더스 ", ""),
      state: state,
      open_time: open_time |> Timex.format!("%H:%M:%S", :strftime),
      close_time: close_time |> Timex.format!("%H:%M:%S", :strftime),
      next_holiday: next_holiday |> Timex.format!("%Y-%m-%d", :strftime)
    }
  end

  def info!("homeplus", name) do
    document =
      IsMartOpenApi.Fetch.fetch_homeplus_html!(name)
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

    close_time =
      if time |> Enum.at(1) |> String.slice(0..1) == "24" do
        {Date.to_erl(today),
         Time.to_erl(
           Timex.parse!("00:#{time |> Enum.at(1) |> String.slice(3..4)}", "%H:%M", :strftime)
         )}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Asia/Seoul")
        |> Date.add(1)
      else
        {Date.to_erl(today), Time.to_erl(Timex.parse!(time |> Enum.at(1), "%H:%M", :strftime))}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Asia/Seoul")
      end

    next_holiday =
      Timex.parse!(element |> Floki.find(".off") |> Floki.text(), "%Y-%m-%d", :strftime)

    state =
      cond do
        Timex.compare(now, next_holiday) == 0 ->
          :holiday_closed

        Timex.compare(now, open_time) == -1 ->
          :before_open

        Timex.compare(now, close_time) == 1 ->
          :after_closed

        true ->
          :open
      end

    %Information{
      name: element |> Floki.find("span.name > a") |> Floki.text(),
      state: state,
      open_time: open_time |> Timex.format!("%H:%M:%S", :strftime),
      close_time: close_time |> Timex.format!("%H:%M:%S", :strftime),
      next_holiday: next_holiday |> Timex.format!("%Y-%m-%d", :strftime)
    }
  end

  def info!("costco", name) do
    json =
      IsMartOpenApi.Fetch.fetch_costco_json!(name)
      |> Enum.filter(fn element -> element["displayName"] == name end)
      |> Enum.at(0)

    today = Timex.today("Asia/Seoul")
    now = Timex.now("Asia/Seoul")

    [open_time, close_time] =
      Regex.run(~r/오전 \d+:\d+ - 오후 \d+:\d+/, json["storeContent"])
      |> Enum.at(0)
      |> String.replace("오전", "AM")
      |> String.replace("오후", "PM")
      |> String.split(" - ")

    open_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(open_time, "{AM} {h12}:{m}"))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")

    close_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(close_time, "{AM} {h12}:{m}"))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")

    next_holiday = parse_costco_holiday(json["storeContent"])

    state =
      cond do
        Timex.compare(today, next_holiday) == 0 ->
          :holiday_closed

        Timex.compare(now, open_time) == -1 ->
          :before_open

        Timex.compare(now, close_time) == 1 ->
          :after_closed

        true ->
          :open
      end

    %Information{
      name: json["displayName"],
      state: state,
      open_time: open_time |> Timex.format!("%H:%M:%S", :strftime),
      close_time: close_time |> Timex.format!("%H:%M:%S", :strftime),
      next_holiday: next_holiday
    }
  end

  def info!("emart_everyday", name) do
    document =
      IsMartOpenApi.Fetch.fetch_emart_everyday_info_json!(name)
      |> Floki.parse_document!()

    time =
      document
      |> Floki.find("td[headers='shopTime']")
      |> Floki.text()
      |> String.split(" ~ ")

    today = Timex.today()
    now = Timex.now("Asia/Seoul")

    open_time =
      {Date.to_erl(today), Time.to_erl(Timex.parse!(time |> Enum.at(0), "%H:%M", :strftime))}
      |> NaiveDateTime.from_erl!()
      |> DateTime.from_naive!("Asia/Seoul")

    close_time =
      if time |> Enum.at(1) |> String.slice(0..1) == "24" do
        {Date.to_erl(today),
         Time.to_erl(
           Timex.parse!("00:#{time |> Enum.at(1) |> String.slice(3..4)}", "%H:%M", :strftime)
         )}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Asia/Seoul")
        |> Date.add(1)
      else
        {Date.to_erl(today), Time.to_erl(Timex.parse!(time |> Enum.at(1), "%H:%M", :strftime))}
        |> NaiveDateTime.from_erl!()
        |> DateTime.from_naive!("Asia/Seoul")
      end

    next_holiday =
      parse_emart_everyday_holiday(
        document
        |> Floki.find("td[headers='shopService']")
        |> Floki.text()
      )

    state =
      cond do
        Timex.compare(now, next_holiday) == 0 ->
          :holiday_closed

        Timex.compare(now, open_time) == -1 ->
          :before_open

        Timex.compare(now, close_time) == 1 ->
          :after_closed

        true ->
          :open
      end

    %Information{
      name: (document |> Floki.find("p.title") |> Floki.text() |> String.trim()) <> "점",
      state: state,
      open_time: open_time |> Timex.format!("%H:%M:%S", :strftime),
      close_time: close_time |> Timex.format!("%H:%M:%S", :strftime),
      next_holiday: next_holiday |> Timex.format!("%Y-%m-%d", :strftime)
    }
  end

  def info!(_, _) do
    nil
  end

  defp parse_costco_holiday(store_content) do
    result = Regex.run(~r/매월 ([첫둘셋넷])째, ([첫둘셋넷])째 ([월화수목금토일])요일/u, store_content)

    if result != nil do
      [_, first_week, second_week, day] = result
      first_week = week_to_number(first_week)
      second_week = week_to_number(second_week)
      day = day_to_number(day)

      today = Timex.now("Asia/Seoul")

      first = calculate_date_from_today(first_week, day)
      second = calculate_date_from_today(second_week, day)

      cond do
        Timex.compare(today, first) != 1 -> first
        Timex.compare(today, second) != 1 -> second
        true -> nil
      end
    else
      [_, first_week, first_day, second_week, second_day] =
        Regex.run(~r/매월 ([첫둘셋넷])째 ([월화수목금토일])요일, ([첫둘셋넷])째 ([월화수목금토일])요일/u, store_content)

      first_week = week_to_number(first_week)
      second_week = week_to_number(second_week)
      first_day = day_to_number(first_day)
      second_day = day_to_number(second_day)

      today = Timex.now("Asia/Seoul")

      first = calculate_date_from_today(first_week, first_day)
      second = calculate_date_from_today(second_week, second_day)

      cond do
        Timex.compare(today, first) != 1 -> first
        Timex.compare(today, second) != 1 -> second
        true -> nil
      end
    end
  end

  defp parse_emart_everyday_holiday(input) do
    [_, first_week, second_week, day] =
      Regex.run(~r/매월 ([첫둘셋넷])째, ([첫둘셋넷])째주 ([월화수목금토일])요일/u, input)

    first_week = week_to_number(first_week)
    second_week = week_to_number(second_week)
    day = day_to_number(day)

    today = Timex.now("Asia/Seoul")

    first = calculate_date_from_today(first_week, day)
    second = calculate_date_from_today(second_week, day)

    cond do
      Timex.compare(today, first) != 1 -> first
      Timex.compare(today, second) != 1 -> second
      true -> nil
    end
  end

  defp week_to_number(input) do
    case input do
      "첫" -> 1
      "둘" -> 2
      "셋" -> 3
      "넷" -> 4
    end
  end

  defp day_to_number(input) do
    case input do
      "월" -> 0
      "화" -> 1
      "수" -> 2
      "목" -> 3
      "금" -> 4
      "토" -> 5
      "일" -> 6
    end
  end

  defp calculate_date_from_today(week, day) do
    today = Timex.today("Asia/Seoul")

    today_week =
      today
      |> Timex.week_of_month()

    today_day =
      today
      |> Timex.days_to_beginning_of_week()

    diff = 7 * (week - today_week) + abs(day - today_day)

    today
    |> Date.add(diff)
  end
end
