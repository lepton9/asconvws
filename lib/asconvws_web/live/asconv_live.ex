defmodule AsconvwsWeb.AsconvLive do
  use AsconvwsWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, mode: :url, ascii: nil, filename: nil, url: "")
    {:ok, allow_upload(socket, :file, accept: ~w(.png .jpg .jpeg .gif), max_entries: 1)}
  end

  def handle_event("toggle_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, mode: String.to_atom(mode))}
  end

  def handle_event("submit", %{"url" => url} = params, socket) when url != "" do
    ascii_result = convert_to_ascii(url)
    {:noreply, assign(socket, ascii: ascii_result, filename: url)}
  end

  def handle_event("submit", _params, socket) do
    case socket.assigns.uploads.file.entries do
      [entry] ->
        {:ok, tmp_path} =
          consume_uploaded_entry(socket, entry, fn %{path: path} ->
            {:ok, path}
          end)

        ascii_result = convert_to_ascii(tmp_path)
        {:noreply, assign(socket, ascii: ascii_result, filename: entry.client_name)}

      [] ->
        {:noreply, socket}
    end
  end

  defp convert_to_ascii(path) do
    # exe = Path.join(:code.priv_dir(:asconvws), "asconv")
    exe = "asconv"

    {out, 0} =
      System.cmd(exe, ["ascii", "-i", path, "-s", "0.1"], stderr_to_stdout: true)

    out
  end

  def render(assigns) do
    ~H"""
    <div>
      <Layouts.top_bar />
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <FileInput.input_form mode={@mode} url={@url} uploads={@uploads} />
      
    <!-- ASCII output -->
      <%= if @ascii do %>
        <FileInput.ascii filename={@filename} ascii={@ascii} />
      <% end %>
    </div>
    """
  end
end
