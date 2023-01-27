defmodule Cryptobot.Coingecko do

  def lookup_market_chart(coin_id) do
    market_chart_url(coin_id)
    |> HTTPoison.get(url)
  end

  def lookup_market_chart!(coin_id) do
    market_chart_url(coin_id)
    |> HTTPoison.get!(url)
  end

  defp market_chart_url(coin_id) do
    coingecko_config = Application.get_env(:cryptobot, :coingecko_config)
    Path.join([coingecko_config.base_url, "coins", coin_id, "?vs_currency=myr&days=14"])
  end

  def search(query) do
    coingecko_config = Application.get_env(:cryptobot, :coingecko_config)
    url = Path.join([coingecko_config.base_url, "search", "?query=#{query}"])
    HTTPoison.get!(url)
  end
end
