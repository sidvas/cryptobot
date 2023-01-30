defmodule Cryptobot.MessageHandler do
  alias Cryptobot.ChatBot
  alias Cryptobot.Coingecko
  alias Cryptobot.MessageHelper

  def reply(%{"text" => "hi"}, event) do
    profile = MessageHelper.get_profile(event)
    MessageHelper.text_reply(event, "Hiya #{profile["first_name"]}, so you wanna search crypto?")
    |> ChatBot.send_message()
    search_by_question(event)
  end

  def reply(msg, event) do
    case File.read("#{MessageHelper.get_sender(event)["id"]}.rnd")  do
      {:ok, id_or_name} ->
        if id_or_name == "id" do
          res = Coingecko.lookup_market_chart!(msg["text"])
          case res do
            %{"error" => _err} ->
              MessageHelper.text_reply(event, "Uh oh no coin found with that ID, try again or type hi to change search type")
              |> ChatBot.send_message()
            _ ->
              if File.exists?("#{MessageHelper.get_sender(event)["id"]}.rnd"), do: File.rm!("#{MessageHelper.get_sender(event)["id"]}.rnd")
              prices_data = MessageHelper.format_data(res["prices"])
              goodbye_msg = "Hope you're satisfied, if you want to search again, just say hi"
              MessageHelper.text_reply(event, prices_data <> goodbye_msg)
              |> ChatBot.send_message()
          end
        else
          results = Coingecko.search!(msg["text"])
          top_5 = Enum.take(results["coins"], 5)
          if top_5 == [] do
            MessageHelper.text_reply(event, "Sorry, no results found, try another search term, or say hi again to change your search type")
            |> ChatBot.send_message()
          else
            buttons = Enum.map(top_5, fn e ->
              {e["name"], e["id"]}
            end)
            if Enum.count(buttons) <= 3 do
              MessageHelper.button_message(event, "Select the coin you want to view stats for; you can search again if your result is not shown or type hi to change your search type", buttons)
              |> ChatBot.send_message()
            else
              MessageHelper.button_message(event, "Select the coin you want to view stats for; you can search again if your result is not shown or type hi to change your search type", Enum.take(buttons, 3))
              |> ChatBot.send_message()
              MessageHelper.button_message(event, "Facebook only allows showing up to 3 buttons, maybe it's one of these?", Enum.slice(buttons, 3..5))
              |> ChatBot.send_message()
            end
          end
        end
      {:error, _s} ->
        MessageHelper.text_reply(event, "Unrecognized command, maybe start with 'hi', it's only polite")
        |> ChatBot.send_message()
    end
  end

  def reply_to_selection(%{"payload" => "search_by_" <> id_or_name}, event) do
    path = "#{MessageHelper.get_sender(event)["id"]}.rnd"

    if id_or_name == "id" do
      File.write!(path, "id")
      MessageHelper.text_reply(event, "Enter your ID, make sure you don't mispell ;)")
      |> ChatBot.send_message()
    else
      File.write!(path, "name")
      MessageHelper.text_reply(event, "What would you like to search?")
      |> ChatBot.send_message()
    end
  end

  def reply_to_selection(%{"payload" => id}, event) do
    if File.exists?("#{MessageHelper.get_sender(event)["id"]}.rnd"), do: File.rm!("#{MessageHelper.get_sender(event)["id"]}.rnd")
    res = Coingecko.lookup_market_chart!(id)
    prices_data = MessageHelper.format_data(res["prices"])
    goodbye_msg = "Hope you're satisfied, if you want to search again, just say hi"
    MessageHelper.text_reply(event, prices_data <> goodbye_msg)
    |> ChatBot.send_message()
  end

  defp search_by_question(event) do
    buttons = [
      {"Name", "search_by_name"},
      {"ID", "search_by_id"}
    ]
    MessageHelper.button_message(event, "Would you like to search by name or if you know the ID, I can look that up directly for you?", buttons)
    |> ChatBot.send_message()
  end
end
