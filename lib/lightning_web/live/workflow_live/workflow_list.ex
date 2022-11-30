defmodule LightningWeb.WorkflowLive.Components do
  @moduledoc false
  use LightningWeb, :component

  def workflow_list(assigns) do
    ~H"""
    <div class="w-full flex flex-wrap gap-4 p-4">
      <.create_workflow_card />
      <%= for workflow <- @page.entries do %>
        <.workflow_card
          workflow={%{workflow | name: workflow.name || "Untitled"}}
          project={@project}
        />
      <% end %>
    </div>
    """
  end

  def workflow_card(assigns) do
    ~H"""
    <div class="w-72 h-44 bg-white rounded-md border shadow p-4 flex flex-col h-full justify-between">
      <.link
        class="font-bold mb-2"
        navigate={
          Routes.project_workflow_path(
            LightningWeb.Endpoint,
            :view_workflow,
            @project.id,
            @workflow.id
          )
        }
      >
        <%= @workflow.name %>
      </.link>
      <div class="">This is the desscription of the workflow and it is harcoded</div>
      <div class="bg-gray-100 w-full h-10 flex items-center justify-center">
        TOOLBAR
      </div>
    </div>
    """
  end

  def create_workflow_card(assigns) do
    ~H"""
    <div class="w-72 h-44 bg-white rounded-md border shadow p-4 flex flex-col h-full justify-between">
      <div class="font-bold mb-2">Create a new workflow</div>
      <div class="">Create a new workfloow for yout organisation</div>
      <div>
        <button
          phx-click="create-workflow"
          class="focus:ring-primary-500 bg-primary-600 hover:bg-primary-700 inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white focus:outline-none focus:ring-2 focus:ring-offset-2"
        >
          Create a workflow
        </button>
      </div>
    </div>
    """
  end
end
