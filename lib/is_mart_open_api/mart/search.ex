defmodule IsMartOpenApi.Search do
  @spec search!(mart :: String.t(), keyword :: String.t()) :: list()
  def search!("emart", keyword) do
    IsMartOpenApi.Fetch.fetch_emart_json!("EM", keyword)
    |> Enum.map(fn element -> element["NAME"] |> String.replace("이마트 ", "") end)
  end

  def search!("traders", keyword) do
    IsMartOpenApi.Fetch.fetch_emart_json!("TR", keyword)
    |> Enum.map(fn element -> element["NAME"] |> String.replace("이마트 트레이더스 ", "") end)
  end

  def search!("homeplus", keyword) do
    document =
      IsMartOpenApi.Fetch.fetch_homeplus_html!(keyword)
      |> Floki.parse_document!()

    document
    |> Floki.find("span.name > a")
    |> Enum.map(fn find -> find |> Floki.text() end)
    |> Enum.filter(fn name -> name |> String.contains?(keyword) end)
  end

  def search!("costco", keyword) do
    IsMartOpenApi.Fetch.fetch_costco_json!(keyword)
    |> Enum.map(fn element -> element["displayName"] end)
    |> Enum.filter(fn name -> name |> String.contains?(keyword) end)
  end

  def search!("emart_everyday", keyword) do
    IsMartOpenApi.Fetch.fetch_emart_everyday_list_json!(keyword)
    |> Enum.map(fn json -> "#{json["name"]}:#{json["seq"]}" end)
  end

  def search!(_, _) do
    []
  end
end
