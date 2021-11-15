defmodule SharedUtils.SentryTest do
  use ExUnit.Case, async: true
  alias SharedUtils.Sentry

  describe "&set_dsn/2" do
    test "return Application haven't started" do
      try do
        Sentry.set_dsn(BlitzAuth.Application)
        # this will set off an error if success
        assert false
      rescue
        e in RuntimeError ->
          assert e.message === "Sentry: can't find app for #{BlitzAuth.Application}"
      end
    end
  end
end
