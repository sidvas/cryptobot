defmodule Cryptobot.ChatBot do
  alias Cryptobot.MessageHandler

  def verify(params) do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    params["hub.mode"] == "subscribe" && params["hub.verify_token"] == facebook_config.webhook_verify_token
  end

  def send_message(msg, event) do
    url = messages_endpoint(event)
    IO.inspect(HTTPoison.post!(url, Jason.encode!(msg), [{"Content-type", "application/json"}]))
  end

  def handle_event(event) do
    case MessageHandler.get_messaging(event) do
      %{"message" => msg} -> MessageHandler.reply_with_bot(msg, event)
      _ ->
        err_msg = MessageHandler.text_reply(event, "GG you messsed something up")
        send_message(err_msg, event)
    end
  end

  def handle_postback(postback) do
    IO.inspect(postback)
  end

  def messages_endpoint(event) do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    Path.join([facebook_config.base_url, facebook_config.api_version, MessageHandler.get_recipient(event)["id"], facebook_config.message_url])
  end
end
