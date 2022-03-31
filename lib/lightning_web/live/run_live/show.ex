defmodule LightningWeb.RunLive.Show do
  @moduledoc """
  LiveView for viewing a single Run
  """
  use LightningWeb, :live_view

  alias Lightning.Invocation

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:run, Invocation.get_run!(id))}
  end

  defp page_title(:show), do: "Show Run"
  defp page_title(:edit), do: "Edit Run"
end