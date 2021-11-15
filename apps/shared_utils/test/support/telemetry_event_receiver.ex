defmodule SharedUtils.TelemetryEventReceiver do
  @moduledoc """
  This module is to test telemetry handlers

  {:ok, pid} = TelemetryEventReceiver.start_link()

  :telemetry.attach(
    "handler_id",
    [:event, :name],
    TelemetryEventReceiver.setup_handle_event_for(pid),
    nil
  )

  :telemetry.execute([:event, :name], %{measurement: "thing"})

  TelemetryEventReceiver.get(pid) # [%{measurement: "thing"}]
  """

  use Agent

  def start_link(opts \\ []) do
    Agent.start_link(fn -> [] end, opts)
  end

  def get(pid), do: Agent.get(pid, & &1)

  def setup_handle_event_for(pid) do
    fn event_name, event_measurements, event_meta, _ ->
      Agent.update(pid, fn state ->
        [{event_name, event_measurements, event_meta} | state]
      end)
    end
  end
end
