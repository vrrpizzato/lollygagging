defmodule LollygaggingWeb.PostLive.Index do
  use LollygaggingWeb, :live_view

  alias Lollygagging.Timeline
  alias Lollygagging.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
    end

    socket =
      socket
      |> push_event("TimezoneHook", %{})
      |> assign(:client_timezone, nil)
      |> assign(:opened, nil)
      |> stream(:posts, [], at: 0, limit: 10)

    {:ok, socket}
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

  defp apply_action(socket, :reply, %{"id" => id}) do
    socket
    |> assign(:page_title, "Reply")
    |> assign(:post, %Post{})
    |> assign(:parent_id, id)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
    |> assign(:parent_id, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Timeline")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({:post_created, %Post{parent_id: nil} = post}, socket) do
    {:noreply, stream_insert(socket, :posts, post, at: 0, limit: 20)}
  end

  @impl true
  def handle_info({:post_created, %Post{parent_id: id}}, socket) do
    post = get_post(id)
    {:noreply, stream_insert(socket, :posts, post, at: -1)}
  end

  @impl true
  def handle_info({:post_updated, %Post{parent_id: nil} = post}, socket) do
    {:noreply, socket |> stream_insert(:posts, post, at: -1)}
  end

  @impl true
  def handle_info({:post_updated, %Post{parent_id: id}}, socket) do
    post = get_post(id)
    {:noreply, socket |> stream_insert(:posts, post, at: -1)}
  end

  @impl true
  def handle_event("reply", %{"id" => id}, socket) do
    post = get_post(id)

    socket =
      if Enum.empty?(post.children) do
        push_patch(socket, to: ~p"/posts/#{id}/new")
      else
        socket
        |> assign(:opened, "post_#{id}_replies")
        |> stream_insert(:posts, post, at: -1)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("liked", %{"id" => id}, socket) do
    {:ok, post} = Timeline.inc_likes(id)
    Timeline.broadcast(post, :post_updated)

    {:noreply, socket}
  end

  @impl true
  def handle_event("fetched_client_timezone", %{"timezone" => timezone}, socket) do
    socket =
      socket
      |> assign(:client_timezone, timezone)
      |> stream(:posts, list_posts(%{parent_id: nil}), reset: true, at: 0, limit: 20)

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, assign(socket, :posts, Enum.reject(socket.assigns.posts, &(&1.id == id)))}
  end

  defp show?(opened, id), do: opened == id

  defp list_posts(criteria) do
    Timeline.list_posts(criteria)
    |> Enum.reverse()
  end

  defp get_post(id) do
    Timeline.get_post!(id)
  end

  defp format_timestamp(timestamp, client_timezone) do
    updated_timestamp = DateTime.shift_zone!(timestamp, client_timezone)

    date =
      updated_timestamp
      |> DateTime.to_date()
      |> Date.to_string()

    time =
      updated_timestamp
      |> DateTime.to_time()
      |> Time.to_string()
      |> String.replace(~r/:([0-9]{2})$/, "")

    "#{date} #{time}"
  end
end
