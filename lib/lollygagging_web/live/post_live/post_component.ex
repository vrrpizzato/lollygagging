defmodule LollygaggingWeb.PostLive.PostComponent do
  use LollygaggingWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id="post-#{@post.id}" class="post box-border min-h-32 min-w-48">
      <div class="flex gap-2.5">
        <div class="flex flex-col w-full max-w-[px] leading-1.5 p-4 rounded-3xl border-gray-200 bg-gray-100">
          <div class="flex items-center space-x-2 rtl:space-x-reverse">
            <span class="text-base font-semibold text-gray-900">@<%= @post.username %></span>
          </div>
          <p class="text-base font-normal py-2.5 text-gray-900"><%= @post.body %></p>

          <div class="flex items-end text-end ">
            <span class="text-sm font-normal text-gray-500 dark:text-gray-400">
              <%= format_timestamp(@post.inserted_at) %>
            </span>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("liked", _unsigned_params, socket) do
    Lollygagging.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  defp format_timestamp(timestamp) do
    date =
      timestamp
      |> DateTime.to_date()
      |> Date.to_string()

    time =
      timestamp
      |> DateTime.to_time()
      |> Time.to_string()
      |> String.replace(~r/:([0-9]{2})$/, "")

    "#{date} #{time}"
  end
end
