defmodule Cryptobot.ChatBot do
  alias Cryptobot.MessageHandler

  def verify(params) do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    params["hub.mode"] == "subscribe" && params["hub.verify_token"] == facebook_config.webhook_verify_token
  end

  def send_message(msg) do
    url = messages_endpoint()
    IO.inspect(url)
    IO.inspect(msg)
    HTTPoison.post!(url, Jason.encode!(msg))
  end

  def handle_event(event) do
    case MessageHandler.get_messaging(event) do
      %{"message" => msg} -> MessageHandler.reply_with_bot(msg, event)
      _ ->
        err_msg = MessageHandler.text_reply(event, "GG you messsed something up")
        send_message(err_msg)
    end
  end

  def messages_endpoint do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    Path.join([facebook_config.base_url, facebook_config.api_version, facebook_config.message_url])
  end
end
