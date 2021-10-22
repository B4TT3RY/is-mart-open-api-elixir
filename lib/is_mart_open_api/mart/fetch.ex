defmodule IsMartOpenApi.Fetch do
  @user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Safari/605.1.15"

  @base_url %{
    emart: "https://store.emart.com/branch/searchList.do",
    homeplus: "https://corporate.homeplus.co.kr/STORE/HyperMarket.aspx",
    costco: "https://www.costco.co.kr/store-finder/search?q=",
    emart_everyday_list: "http://www.emarteveryday.co.kr/branch/searchBranch.jsp",
    emart_everyday_info: "http://www.emarteveryday.co.kr/branch/branchView.jsp"
  }

  @homeplus_viewstate "/wEPDwUJLTc2MDkzMDI3D2QWAmYPZBYCAgUPZBYCAgEPZBYCAgEPEGRkFgFmZBgBBR5fX0NvbnRyb2xzUmVxdWlyZVBvc3RCYWNrS2V5X18WAwUkY3RsMDAkQ29udGVudFBsYWNlSG9sZGVyMSRzdG9yZXR5cGUxBSRjdGwwMCRDb250ZW50UGxhY2VIb2xkZXIxJHN0b3JldHlwZTIFJGN0bDAwJENvbnRlbnRQbGFjZUhvbGRlcjEkc3RvcmV0eXBlM+aYO9PJofU5uQQJJZRZ2bboir3I"

  @spec do_fetch_emart_json!(search_type :: String.t(), keyword :: String.t()) :: list()
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
         ]},
        [
          {"User-Agent", @user_agent}
        ]
      )

    response.body
    |> Jason.decode!()
    |> Map.fetch!("dataList")
  end

  @spec do_fetch_homeplus_html!(keyword :: String.t()) :: String.t()
  def do_fetch_homeplus_html!(keyword) do
    response =
      HTTPoison.post!(
        @base_url.homeplus,
        {:form,
         [
           {"__VIEWSTATE", @homeplus_viewstate},
           {"ctl00$ContentPlaceHolder1$srch_name", keyword},
           {"ctl00$ContentPlaceHolder1$storetype1", "on"}
         ]},
        [
          {"User-Agent", @user_agent}
        ]
      )

    response.body
  end

  @spec do_fetch_costco_json!(keyword :: String.t()) :: list()
  def do_fetch_costco_json!(keyword) do
    response = HTTPoison.get!("#{@base_url.costco}#{keyword |> URI.encode()}")

    response.body
    |> Jason.decode!()
    |> Map.fetch!("data")
  end

  @spec do_fetch_emart_everyday_list_json!(keyword :: String.t()) :: list()
  def do_fetch_emart_everyday_list_json!(keyword) do
    response =
      HTTPoison.post!(
        @base_url.emart_everyday_list,
        {:form,
         [
           {"region", ""}
         ]},
        [
          {"User-Agent", @user_agent}
        ]
      )

    response.body
    |> String.replace(~r/(branchs|name|seq)/, "\"\\g{1}\"")
    |> String.replace("'", "\"")
    |> Jason.decode!()
    |> Map.fetch!("branchs")
    |> Enum.filter(fn json -> json["name"] |> String.contains?(keyword) end)
  end

  @spec do_fetch_emart_everyday_info_json!(keyword :: String.t()) :: String.t()
  def do_fetch_emart_everyday_info_json!(id) do
    response =
      HTTPoison.post!(
        @base_url.emart_everyday_info,
        {:form,
         [
           {"seq", id}
         ]},
        [
          {"User-Agent", @user_agent}
        ]
      )

    response.body
  end
end
