defmodule SharedUtils.ErrorTest do
  use ExUnit.Case, async: true
  alias SharedUtils.Error

  describe "Error message" do
    test "able to send in message" do
      result = Error.not_found("404 bad")
      assert result === %{code: :not_found, message: "404 bad"}
    end

    test "able to send in message and details" do
      result = Error.bad_request("cannot process", "Bad manners")
      assert result === %{code: :bad_request, details: "Bad manners", message: "cannot process"}
    end

    test "able to send in message and a bunch of details" do
      result = Error.bad_request("cannot process", issue: "Some errors", general: "Bad manners")

      assert result === %{
               code: :bad_request,
               details: [issue: "Some errors", general: "Bad manners"],
               message: "cannot process"
             }
    end
  end

  describe "make_details_inspected" do
    test "no details will return error only" do
      assert Error.make_details_inspected(%{thing: 1}) === %{thing: 1}
    end

    test "will return inspected details error if details are in a map" do
      assert Error.make_details_inspected(%{
               error: 403,
               details: %{issue: "Some errors", general: "Bad manners"}
             }) ===
               %{error: 403, details: inspect(%{issue: "Some errors", general: "Bad manners"})}
    end

    test "will return no inspected details error if no details key provided" do
      assert Error.make_details_inspected(%{
               error: 403,
               issue: "Some errors",
               general: "Bad manners"
             }) ===
               %{error: 403, issue: "Some errors", general: "Bad manners"}
    end

    test "will return inspected details error if details are in keywords" do
      assert Error.make_details_inspected(%{error: 404, details: [issue: "Bad url"]}) ===
               %{
                 error: 404,
                 details:
                   inspect(%{
                     issue: "Bad url"
                   })
               }
    end

    test "will return inspected details error if details are in list" do
      assert Error.make_details_inspected(%{
               error: 404,
               details: ["Bad url", "Wrong address", "Something"]
             }) ===
               %{error: 404, details: inspect(["Bad url", "Wrong address", "Something"])}
    end

    test "will return inspected details error if details are in tuple" do
      assert Error.make_details_inspected(%{
               error: 404,
               details: [{:issue, "Bad url"}, {:something, "worst"}]
             }) ===
               %{
                 error: 404,
                 details:
                   inspect(%{
                     issue: "Bad url",
                     something: "worst"
                   })
               }
    end
  end

  describe "make_error_jsonable" do
    test "no details will return json error only" do
      assert Error.make_error_jsonable(%{thing: 1}) === %{thing: 1}
    end

    test "will return details error if details are in a map" do
      assert Error.make_error_jsonable(%{
               error: 403,
               details: %{issue: "Spit on server", general: "Bad manners"}
             }) ===
               %{error: 403, details: %{issue: "Spit on server", general: "Bad manners"}}
    end

    test "will return details error if details are in keywords" do
      assert Error.make_error_jsonable(%{error: 404, details: [issue: "Bad url"]}) ===
               %{
                 error: 404,
                 details: %{
                   issue: "Bad url"
                 }
               }
    end
  end
end
