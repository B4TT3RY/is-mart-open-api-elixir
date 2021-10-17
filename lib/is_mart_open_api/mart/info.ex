defmodule IsMartOpenApi.Info do
  defmodule Information do
    @derive Jason.Encoder
    defstruct [:name, :state, :open_time, :close_time, :next_holiday]
  end

  @spec info!(mart :: String.t(), keyword :: String.t()) :: Information | nil
  def info!("emart", keyword) do
    json = IsMartOpenApi.Fetch.do_fetch_emart_json!("EM", keyword)
    |> Enum.filter(fn element -> element["NAME"] == "이마트 " <> keyword end)
    |> Enum.at(0)

    %Information {
      name: json["NAME"],
      state: :open,
      open_time: json["OPEN_SHOPPING_TIME"],
      close_time: json["CLOSE_SHOPPING_TIME"],
      next_holiday: json["HOLIDAY_DAY1_YYYYMMDD"]
    }
  end

  def info!("traders", keyword) do
    json = IsMartOpenApi.Fetch.do_fetch_emart_json!("TR", keyword)
    |> Enum.filter(fn element -> element["NAME"] == "이마트 트레이더스 " <> keyword end)
    |> Enum.at(0)

    %Information {
      name: json["NAME"],
      state: :open,
      open_time: json["OPEN_SHOPPING_TIME"],
      close_time: json["CLOSE_SHOPPING_TIME"],
      next_holiday: json["HOLIDAY_DAY1_YYYYMMDD"]
    }
  end

  def info!(_, _) do
    nil
  end
end
