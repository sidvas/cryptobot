defmodule Cryptobot.Coingecko do

  def lookup_market_chart(coin_id) do
    market_chart_url(coin_id)
    |> HTTPoison.get()
  end

  def lookup_market_chart!(coin_id) do
    res =
      market_chart_url(coin_id)
      |> HTTPoison.get!()
    Jason.decode!(res.body)
  end

  defp market_chart_url(coin_id) do
    coingecko_config = Application.get_env(:cryptobot, :coingecko_config)
    Path.join([coingecko_config.base_url, "coins", coin_id, "market_chart", "?vs_currency=usd&days=14&interval=daily"])
  end

  def search!(query) do
    coingecko_config = Application.get_env(:cryptobot, :coingecko_config)
    url = Path.join([coingecko_config.base_url, "search", "?query=#{query}"])
    res = HTTPoison.get!(url)
    Jason.decode!(res.body)
  end
end
