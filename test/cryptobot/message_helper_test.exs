defmodule Cryptobot.MessageHelperTest do
  use ExUnit.Case
  alias Cryptobot.MessageHelper

  @valid_event %{"entry" => [%{"id" => "113465351645763", "messaging" => [%{"postback" => %{"mid" => "m_uVXFriV91wPA08m0nTQWi-JXUNr1kZeP2vbWXfgr0GfE6LVJUO86pi15K6JAfD13EgTDrhY9NGDPXxnTuv5vBg", "payload" => "dogecoin", "title" => "Dogecoin"}, "recipient" => %{"id" => "113465351645763"}, "sender" => %{"id" => "5783568108417962"}, "timestamp" => 1675064574403}], "time" => 1675064574787}], "object" => "page"}
  @bad_event %{"entry" => []}
  test "get_messaging from a valid event" do
    assert is_map(MessageHelper.get_messaging(@valid_event))
  end

  test "get_messaging fails on a bad event" do
    catch_error MessageHelper.get_messaging(@bad_event)
  end

  test "get_sender can extract sender from valid event" do
    assert is_binary(MessageHelper.get_sender(@valid_event)["id"])
  end

  test "get_recipient can extract recipient from valid event" do
    assert is_binary(MessageHelper.get_recipient(@valid_event)["id"])
  end

  test "text_reply returns correct request format for FB text message" do
    res = MessageHelper.text_reply(@valid_event, "something")

    assert res["recipient"]["id"] != nil
    assert res["recipient"]["id"] == MessageHelper.get_sender(@valid_event)["id"]
    assert res["message"]["text"] == "something"
    assert res["messaging_type"] == "RESPONSE"
  end

  test "button_message returns correct request format for FB button message" do
    res = MessageHelper.button_message(@valid_event, "some text", [{"buttonA", "a"}])
    message = res["message"]["attachment"]

    assert res["recipient"]["id"] == MessageHelper.get_sender(@valid_event)["id"]
    assert message["type"] == "template"
    assert message["payload"]["template_type"] == "button"
    assert is_list(message["payload"]["buttons"])
    assert is_binary(message["payload"]["text"])
  end
end
