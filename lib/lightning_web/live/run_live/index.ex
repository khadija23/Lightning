defmodule LightningWeb.RunLive.Index do
  @moduledoc """
  Index Liveview for Runs
  """
  use LightningWeb, :live_view

  alias Lightning.Invocation
  alias Lightning.Invocation.Run

  alias Lightning.RunSearchForm
  alias Lightning.RunSearchForm.RunStatusOption

  on_mount {LightningWeb.Hooks, :project_scope}

  @run_statuses [
    %RunStatusOption{id: :success, label: "Success", selected: true},
    %RunStatusOption{id: :failure, label: "Failure", selected: true},
    %RunStatusOption{id: :timeout, label: "Timeout", selected: true},
    %RunStatusOption{id: :crash, label: "Crash", selected: true},
    %RunStatusOption{id: :pending, label: "Pending", selected: true}
  ]

  @impl true
  def mount(_params, _session, socket) do
    workflows =
      Lightning.Workflows.get_workflows_for(socket.assigns.project)
      |> Enum.map(&{&1.name, &1.id})

    {:ok,
     socket
     |> assign(
       active_menu_item: :runs,
       work_orders: [],
       pagination_path:
         &Routes.project_run_index_path(
           socket,
           :index,
           socket.assigns.project,
           &1
         )
     )
     |> init_filter(statuses: @run_statuses, workflows: workflows)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp build_filter(socket) do
    status =
      socket.assigns.run_statuses
      |> Enum.filter(&(&1.selected in [true, "true"]))
      |> Enum.map(& &1.id)

    [
      status: status,
      workflow_id: socket.assigns.workflow_id,
      date_after: socket.assigns.date_after,
      date_before: socket.assigns.date_before
    ]
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(
      page_title: "Runs",
      run: %Run{},
      page:
        Invocation.list_work_orders_for_project(
          socket.assigns.project,
          build_filter(socket),
          params
        )
    )
  end

  @impl true
  def handle_info({:selected_statuses, statuses}, socket) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_embed(:options, statuses)

    {:noreply,
     socket
     |> assign(:run_statuses, statuses)
     |> assign(:changeset, changeset)
     |> push_patch(
       to:
         Routes.project_run_index_path(
           socket,
           :index,
           socket.assigns.project
         ),
       replace: true
     )}
  end

  @impl true
  def handle_event(
        "selected_workflow",
        %{"run_search_form" => %{"workflow_id" => workflow_id}},
        socket
      ) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:workflow_id, workflow_id)

    {:noreply,
     socket
     |> assign(:workflow_id, workflow_id)
     |> assign(:changeset, changeset)
     |> push_patch(
       to:
         Routes.project_run_index_path(
           socket,
           :index,
           socket.assigns.project
         ),
       replace: true
     )}
  end

  def handle_event(
        "change_after",
        %{"run_search_form" => %{"date_after" => date_after}},
        socket
      ) do
    date_after =
      case date_after do
        "" -> nil
        date -> Timex.parse!(date, "{ISO:Extended}")
      end

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:date_after, date_after)

    {:noreply,
     socket
     |> assign(:date_after, date_after)
     |> assign(:changeset, changeset)
     |> push_patch(
       to:
         Routes.project_run_index_path(
           socket,
           :index,
           socket.assigns.project
         ),
       replace: true
     )}
  end

  def handle_event(
        "change_before",
        %{"run_search_form" => %{"date_before" => date_before}},
        socket
      ) do
    case date_before do
      "" -> nil
      date -> Timex.parse!(date, "{ISO:Extended}")
    end

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_change(:date_before, date_before)

    {:noreply,
     socket
     |> assign(:date_before, date_before)
     |> assign(:changeset, changeset)
     |> push_patch(
       to:
         Routes.project_run_index_path(
           socket,
           :index,
           socket.assigns.project
         ),
       replace: true
     )}
  end

  defp init_filter(socket, statuses: statuses, workflows: workflows) do
    changeset = build_changeset(statuses)

    socket
    |> assign(:changeset, changeset)
    |> assign(:run_statuses, statuses)
    |> assign(:workflows, workflows)
    |> assign(:workflow_id, "")
    |> assign(:date_after, "")
    |> assign(:date_before, "")
  end

  defp build_changeset(statuses) do
    %RunSearchForm{}
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:options, statuses)
    |> Ecto.Changeset.put_change(:workflow_id, "")
  end
end
