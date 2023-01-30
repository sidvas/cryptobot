defmodule Cryptobot.ChatBotTest do
  use ExUnit.Case
  alias Cryptobot.ChatBot


  @valid_params %{"hub.verify_token": "something", "hub.mode": "subscribe"}
  test "valid params for verify" do
    res = ChatBot.verify(@valid_params)
    assert is_binary(@valid_params."hub.mode")
    assert @valid_params."hub.mode" == "subscribe"
    assert is_binary(@valid_params."hub.verify_token")
    assert res == true or res == false
  end


  @dummy_msg %{recipient: "23542345", messaging_type: "something", message: %{text: "this"}}
  test "send message calls facebook send API" do
    res = ChatBot.send_message(@dummy_msg)
    assert res.request_url =~ "graph.facebook.com"
    assert res.request.body =~ @dummy_msg.message.text
    assert Enum.member?(res.request.headers, {"Content-type", "application/json"})
  end

  test "handle_webhook won't accept event that is not according to FB guidelines" do
    catch_error ChatBot.handle_webhook(%{event: "bad_event"})
  end
end
