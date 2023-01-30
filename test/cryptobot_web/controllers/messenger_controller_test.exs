defmodule CryptobotWeb.MessengerControllerTest do
  use CryptobotWeb.ConnCase

  @valid_verify_params %{"hub.challenge": "something", "hub.mode": "subscribe", "hub.verify_token": "exists"}
  test "GET /api/messenger_webhook to check for valid fb verification flow" do
    conn = build_conn(:get, "/api/webhook", @valid_verify_params)
    assert conn.params["hub.mode"] == "subscribe"
    assert is_binary(conn.params["hub.challenge"])
    assert is_binary(conn.params["hub.verify_token"])
  end
end
