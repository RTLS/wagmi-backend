defmodule SharedUtils.RegexTest do
  use ExUnit.Case, async: true

  describe "url" do
    test "will always match websites" do
      assert String.match?("www.something.com", SharedUtils.Regex.url())
      assert String.match?("www.something.edu", SharedUtils.Regex.url())
      assert String.match?("https://www.something.edu", SharedUtils.Regex.url())
    end

    test "will not match anything else" do
      refute String.match?("111111", SharedUtils.Regex.url())
      refute String.match?("dog", SharedUtils.Regex.url())
      refute String.match?("2dogs", SharedUtils.Regex.url())
    end
  end

  describe "iso_8601" do
    test "will always match legit iso 8601 format" do
      assert String.match?("2021-01-27T23:07:21Z", SharedUtils.Regex.iso_8601())
    end

    test "will not match other format else" do
      refute String.match?("2021-01-27", SharedUtils.Regex.iso_8601())
      refute String.match?("01-27-2021", SharedUtils.Regex.iso_8601())
      refute String.match?("27-2021-01", SharedUtils.Regex.iso_8601())
      refute String.match?("20210127T230721M", SharedUtils.Regex.iso_8601())
    end
  end

  describe "username" do
    test "will always match legit username" do
      assert String.match?("baconman123", SharedUtils.Regex.username())
    end

    test "will not match with strange characters" do
      refute String.match?("AC-DC", SharedUtils.Regex.username())
      refute String.match?("<+++www---<", SharedUtils.Regex.username())
      refute String.match?("vU.Uv", SharedUtils.Regex.username())
      refute String.match?(";0-0;", SharedUtils.Regex.username())
    end
  end

  describe "no_white_space" do
    test "will clear no whitespace" do
      assert String.match?("baconman123", SharedUtils.Regex.no_white_space())
      assert String.match?("AC-DC", SharedUtils.Regex.no_white_space())
      assert String.match?("<+++www---<", SharedUtils.Regex.no_white_space())
      assert String.match?(".", SharedUtils.Regex.no_white_space())
      assert String.match?("-", SharedUtils.Regex.no_white_space())
    end

    test "will return false if white space detected" do
      refute String.match?("AC DC", SharedUtils.Regex.no_white_space())
      refute String.match?("<+++  ---<", SharedUtils.Regex.no_white_space())
      refute String.match?(" A ", SharedUtils.Regex.no_white_space())
      refute String.match?("H B O;", SharedUtils.Regex.no_white_space())
    end
  end

  describe "pos_float" do
    test "will pass all postive float" do
      assert String.match?("123.11", SharedUtils.Regex.pos_float())
      assert String.match?("11", SharedUtils.Regex.pos_float())
      assert String.match?("0.000000001", SharedUtils.Regex.pos_float())
      assert String.match?("0.00000000000000001", SharedUtils.Regex.pos_float())
      assert String.match?("0", SharedUtils.Regex.pos_float())
    end

    test "will return false negative or letters detected" do
      refute String.match?("-1", SharedUtils.Regex.pos_float())
      refute String.match?("-0.00001", SharedUtils.Regex.pos_float())
      refute String.match?("-99", SharedUtils.Regex.pos_float())
      refute String.match?("H", SharedUtils.Regex.pos_float())
    end
  end

  describe "pos_integer" do
    test "will pass all postive integer" do
      assert String.match?("11", SharedUtils.Regex.pos_integer())
      assert String.match?("21", SharedUtils.Regex.pos_integer())
    end

    test "will return false if float, 0, negative or letters detected" do
      refute String.match?("0", SharedUtils.Regex.pos_integer())
      refute String.match?("0.00000000000000001", SharedUtils.Regex.pos_integer())
      refute String.match?("123.11", SharedUtils.Regex.pos_integer())
      refute String.match?("-1", SharedUtils.Regex.pos_integer())
      refute String.match?("-0.00001", SharedUtils.Regex.pos_integer())
      refute String.match?("-99", SharedUtils.Regex.pos_integer())
      refute String.match?("H", SharedUtils.Regex.pos_integer())
    end
  end

  describe "non_neg_integer" do
    test "will pass all integer 0 or above" do
      assert String.match?("11", SharedUtils.Regex.non_neg_integer())
      assert String.match?("21", SharedUtils.Regex.non_neg_integer())
      assert String.match?("0", SharedUtils.Regex.non_neg_integer())
    end

    test "will return false if float, negative or letters detected" do
      refute String.match?("0.00000000000000001", SharedUtils.Regex.non_neg_integer())
      refute String.match?("123.11", SharedUtils.Regex.non_neg_integer())
      refute String.match?("-1", SharedUtils.Regex.non_neg_integer())
      refute String.match?("-0.00001", SharedUtils.Regex.non_neg_integer())
      refute String.match?("-99", SharedUtils.Regex.non_neg_integer())
      refute String.match?("H", SharedUtils.Regex.non_neg_integer())
    end
  end

  describe "semver" do
    test "will pass if semver is right" do
      assert String.match?("11.1.2", SharedUtils.Regex.semver())
      assert String.match?("1.321.4", SharedUtils.Regex.semver())
    end

    test "will return false semver format is wrong" do
      refute String.match?("0", SharedUtils.Regex.semver())
      refute String.match?("a123.11", SharedUtils.Regex.semver())
      refute String.match?("-1.2", SharedUtils.Regex.semver())
    end
  end

  describe "patch" do
    test "will pass if patch is right format" do
      assert String.match?("11.1", SharedUtils.Regex.patch())
      assert String.match?("1.321", SharedUtils.Regex.patch())
      assert String.match?("0", SharedUtils.Regex.patch())
    end

    test "will return false semver format is wrong" do
      refute String.match?("a123.11", SharedUtils.Regex.patch())
      refute String.match?("-1.2", SharedUtils.Regex.patch())
    end
  end

  describe "region_match_id" do
    test "matches for region and match_id" do
      assert %{"region" => "na1", "match_id" => "12345"} =
               Regex.named_captures(SharedUtils.Regex.region_match_id(), "na1_12345")
    end
  end
end
