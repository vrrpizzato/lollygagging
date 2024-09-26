defmodule LollygaggingWeb.PostLive.Index do
  use LollygaggingWeb, :live_view

  alias Lollygagging.Timeline
  alias Lollygagging.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()

    {:ok,
     socket |> assign(:client_timezone, nil) |> stream(:posts, list_posts(), at: 0, limit: 10)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Timeline")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0, limit: 10)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply, socket |> stream_insert(:posts, post, at: -1)}
  end

  @impl true
  def handle_event("liked", %{"id" => id}, socket) do
    {:ok, post} = Timeline.inc_likes(id)
    Timeline.broadcast(post, :post_updated)

    {:noreply, socket}
  end

  @impl true
  def handle_event("client_timezone", %{"timezone" => timezone}, socket) do
    {:noreply, assign(socket, :client_timezone, timezone)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, assign(socket, :posts, Enum.reject(socket.assigns.posts, &(&1.id == id)))}
  end

  defp list_posts do
    Timeline.list_posts(:desc)
  end

  defp format_timestamp(timestamp) do
    date =
      timestamp
      |> DateTime.to_date()
      |> Date.to_string()

    time =
      timestamp
      # |> DateTime.shift_zone!(client_timezone)
      |> DateTime.to_time()
      |> Time.to_string()
      |> String.replace(~r/:([0-9]{2})$/, "")

    "#{date} #{time}"
  end
end
