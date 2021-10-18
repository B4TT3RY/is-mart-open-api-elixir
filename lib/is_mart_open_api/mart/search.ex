defmodule IsMartOpenApi.Search do
  @spec search!(mart :: String.t(), keyword :: String.t()) :: list()
  def search!("emart", keyword) do
    IsMartOpenApi.Fetch.do_fetch_emart_json!("EM", keyword)
    |> Enum.map(fn element -> element["NAME"] |> String.replace("이마트 ", "") end)
  end

  def search!("traders", keyword) do
    IsMartOpenApi.Fetch.do_fetch_emart_json!("TR", keyword)
    |> Enum.map(fn element -> element["NAME"] |> String.replace("이마트 트레이더스 ", "") end)
  end

  def search!("homeplus", keyword) do
    document =
      IsMartOpenApi.Fetch.do_fetch_homeplus_html!(keyword)
      |> Floki.parse_document!()

    document
    |> Floki.find("span.name > a")
    |> Enum.map(fn find -> find |> Floki.text end)
  end

  def search!(_, _) do
    []
  end
end
