defmodule Cryptobot.MessageHandler do
  alias Cryptobot.ChatBot
  alias Cryptobot.Coingecko

  def get_sender(event) do
    messaging = get_messaging(event)
    messaging["sender"]
  end

  def get_recipient(event) do
    messaging = get_messaging(event)
    messaging["recipient"]
  end

  def get_messaging(event) do
    [entry | _x] = event["entry"]
    [messaging | _x] = entry["messaging"]
    messaging
  end

  def get_message(event) do
    messaging = get_messaging(event)
    messaging["message"]
  end

  def get_profile(event) do
    sender = get_sender(event)
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    token_path = "?access_token=#{facebook_config.page_access_token}"
    profile_url = Path.join([facebook_config.base_url, facebook_config.api_version, sender["id"], token_path])

    res = HTTPoison.get!(profile_url)
    Jason.decode!(res.body)
  end

  def text_reply(event, text) do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)

    %{"recipient" =>
      %{
        "id" => get_sender(event)["id"]
      },
      "message" =>  %{"text" => text},
      "messaging_type" => "RESPONSE",
      "access_token" => "#{facebook_config.page_access_token}"
    }
  end

  def button_message(event, text, buttons) do
    buttons = Enum.map(buttons, &format_postback_button/1)
    payload = %{
      "template_type" => "button",
      "text" => text,
      "buttons" => buttons
    }
    recipient = %{"id" => get_sender(event)["id"]}
    message = %{"attachment" => format_attachment(payload)}

    format_template(recipient, message)
  end


  defp format_postback_button({title, payload}) do
    %{
      "type" => "postback",
      "title" => title,
      "payload" => payload
    }
  end

  defp format_attachment(payload) do
    %{
      "type" => "template",
      "payload" => payload
    }
  end

  defp format_template(recipient, message) do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)

    %{
      "message" => message,
      "recipient" => recipient,
      "messaging_type" => "UPDATE",
      "access_token" => "#{facebook_config.page_access_token}"
    }
  end

  def reply(%{"text" => "hi"}, event) do
    profile = get_profile(event)
    text_reply(event, "Hiya #{profile["first_name"]}, so you wanna search crypto?")
    |> ChatBot.send_message()
    search_by_question(event)
  end

  def reply(msg, event) do
    case File.read("#{get_sender(event)["id"]}.rnd")  do
      {:ok, id_or_name} ->
        if id_or_name == "id" do
          case Coingecko.lookup_market_chart(msg["text"]) do
            {:ok, res} ->
              File.rm!("#{get_sender(event)["id"]}.rnd")
              text_reply(event, res.body["prices"])
              |> ChatBot.send_message()
            {:error, _s} ->
              text_reply(event, "Uh oh no coin found with that ID")
              |> ChatBot.send_message()
          end
        else
          res = Coingecko.search(id_or_name)
          top_5 = Enum.take(res.body["coins"], 5)
          if top_5 == [] do
            text_reply(event, "Sorry, no results found, try another search term, or say hi again to change your search type")
            |> ChatBot.send_message()
          else
            buttons = Enum.map(top_5, fn e ->
              {e["name"], e["id"]}
            end)
            button_message(event, "Select the coin you want to view stats for; you can search again if your result is not shown", buttons)
            |> ChatBot.send_message()
          end
        end
      {:error, _s} ->
        text_reply(event, "Unrecognized command, maybe start with 'hi', it's only polite")
        |> ChatBot.send_message()
    end
  end

  def reply_to_selection(%{"payload" => "search_by" <> id_or_name}, event) do
    path = "#{get_sender(event)["id"]}.rnd"

    if id_or_name == "id" do
      File.write!(path, "id")
      text_reply(event, "Enter your ID, make sure you don't mispell ;)")
      |> ChatBot.send_message()
    else
      File.write!(path, "name")
      text_reply(event, "What would you like to search?")
      |> ChatBot.send_message()
    end
  end

  def reply_to_selection(%{"payload" => id}, event) do
    File.rm!("#{get_sender(event)["id"])
    res = Coingecko.lookup_market_chart!(id)
    text_reply(event, res.body["prices"])
    |> ChatBot.send_message()
  end

  defp search_by_question(event) do
    buttons = [
      {"Name", "search_by_name"},
      {"ID", "search_by_id"}
    ]
    button_message(event, "Would you like to search by name or if you know the ID, I can look that up directly for you?", buttons)
    |> ChatBot.send_message()
  end
end
