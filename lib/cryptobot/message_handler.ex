defmodule Cryptobot.MessageHandler do
  alias Cryptobot.ChatBot

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

  def reply_with_bot(%{"text" => "hi"}, event) do
    profile = get_profile(event)
    reply = text_reply(event, "Hiya #{profile["first_name"]}")
    ChatBot.send_message(reply, event)
  end

  def reply_with_bot(_msg, event) do
    reply = text_reply(event, "Unrecognized command, rtfi")
    ChatBot.send_message(reply, event)
  end
end
