defmodule RhymeThymeWeb.SearchLive do
  use Phoenix.LiveView
  require Logger

  def render(assigns) do
    ~L"""
    <form phx-change="suggest" phx-submit="search">
      <input type="text" name="qrhyme" value="<%= @query %>" placeholder="Search..."
             <%= if @loading, do: "readonly" %>/>
      <%= if is_list(@result) do %>
        <ul id="rhymes">
          <%= for result <- @result do %>
            <li><%=result%></li>
          <% end %>
        </ul>
      <% end %>
    </form>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, query: nil, result: nil, loading: false, matches: [])}
  end

  def handle_event("suggest", %{"qrhyme" => query}, socket) when byte_size(query) <= 100 do
    # {words, _} = System.cmd("grep", ~w"^#{query}.* -m 5 /usr/share/dict/words")
    # {:noreply, assign(socket, matches: String.split(words, "\n"))}
    {timing, result} = :timer.tc(fn -> RhymeThyme.RhymeEngine.rhymes_with(query) end)
    Logger.debug("rhyme search for #{inspect query}: #{timing}µs")
    {:noreply, assign(socket, loading: false, result: result, matches: [])}
  end

  def handle_event("search", %{"qrhyme" => query}, socket) when byte_size(query) <= 100 do
    send(self(), {:search, query})
    {:noreply, assign(socket, query: query, result: "Searching...", loading: true, matches: [])}
  end

  def handle_info({:search, query}, socket) do
    {timing, result} = :timer.tc(fn -> RhymeThyme.RhymeEngine.rhymes_with(query) end)
    Logger.debug("rhyme search for #{inspect query}: #{timing}µs")
    {:noreply, assign(socket, loading: false, result: result, matches: [])}
  end
end
