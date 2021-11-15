defmodule SharedUtils.HTTPTest do
  use ExUnit.Case, async: true

  @url "https://example.ca"

  describe "&post/4" do
    test "sends post request and can get returned 200" do
      map = %{bill: 321}
      json = Jason.encode!(map)

      assert {:ok,
              {map,
               %SharedUtils.HTTP.Response{
                 body: ^json,
                 status: 200
               }}} =
               SharedUtils.HTTP.post(@url, "", [],
                 http: [
                   post: fn _, _, _, _ ->
                     {:ok,
                      %SharedUtils.HTTP.Response{
                        body: json,
                        headers: [],
                        status: 200,
                        request: %{}
                      }}
                   end
                 ]
               )
    end
  end

  describe "&get/4" do
    test "calls get and deserialized 200 as {:ok, asff}" do
      map = %{bill: 123}
      json = Jason.encode!(map)

      assert {:ok,
              {map,
               %SharedUtils.HTTP.Response{
                 body: ^json,
                 status: 200
               }}} =
               SharedUtils.HTTP.get(@url, [],
                 http: [
                   get: fn _, _, _ ->
                     {:ok,
                      %SharedUtils.HTTP.Response{
                        body: json,
                        headers: [],
                        status: 200,
                        request: %{}
                      }}
                   end
                 ]
               )
    end

    test "serializes query params properly" do
      assert {:ok, {map, %SharedUtils.HTTP.Response{}}} =
               SharedUtils.HTTP.get(@url, [],
                 params: %{test: 1},
                 http: [
                   get: fn url, _, _ ->
                     {:ok,
                      %SharedUtils.HTTP.Response{
                        body: Jason.encode!(%{url: url}),
                        headers: [],
                        status: 200,
                        request: %{}
                      }}
                   end
                 ]
               )

      assert String.ends_with?(map["url"], "?test=1")
    end

    test "returns error on non 200 status code" do
      assert {:error, %{code: :bad_request}} =
               SharedUtils.HTTP.get(@url, [],
                 http: [
                   get: fn _, _, _ ->
                     {:ok,
                      %SharedUtils.HTTP.Response{
                        body: nil,
                        headers: [],
                        status: 400,
                        request: %{}
                      }}
                   end
                 ]
               )
    end
  end
end
