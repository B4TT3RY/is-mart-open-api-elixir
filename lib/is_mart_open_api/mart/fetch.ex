defmodule IsMartOpenApi.Fetch do
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"

  @base_url %{
    emart: "https://store.emart.com/branch/searchList.do",
    homeplus: "https://corporate.homeplus.co.kr/STORE/HyperMarket.aspx",
    costco: "https://www.costco.co.kr/store-finder/search?q="
  }

  @homeplus_viewstate "/wEPDwUJLTc2MDkzMDI3D2QWAmYPZBYCAgUPZBYCAgEPZBYCAgEPEGRkFgFmZBgBBR5fX0NvbnRyb2xzUmVxdWlyZVBvc3RCYWNrS2V5X18WAwUkY3RsMDAkQ29udGVudFBsYWNlSG9sZGVyMSRzdG9yZXR5cGUxBSRjdGwwMCRDb250ZW50UGxhY2VIb2xkZXIxJHN0b3JldHlwZTIFJGN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkc3RvcmV0eXBlM+aYO9PJofU5uQQJJZRZ2bboir3I"

  @spec do_fetch_emart_json!(search_type :: String.t(), keyword :: String.t()) :: any
  def do_fetch_emart_json!(search_type, keyword) do
    today = Timex.today("Asia/Seoul")

    response =
      HTTPoison.post!(
        @base_url.emart,
        {:form,
          [
            srchMode: "jijum",
            year: today.year,
            month: today.month,
            jMode: true,
            strConfirmYN: "N",
            searchType: search_type,
            keyword: keyword
          ]
        },
        [
          {"User-Agent", @user_agent}
        ]
      )

      response.body
      |> Jason.decode!()
      |> Map.fetch!("dataList")
  end
end
