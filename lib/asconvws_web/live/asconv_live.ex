defmodule AsconvwsWeb.AsconvLive do
  use AsconvwsWeb, :live_view

  def mount(_params, _session, socket) do
    form = to_form(%{}, as: "input")

    {:ok,
     socket
     |> assign(form: form, mode: :url, ascii: nil, filename: nil, url: "")
     |> allow_upload(:file, accept: ~w(.png .jpg .jpeg .gif), max_entries: 1)}
  end

  def handle_event("toggle_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, mode: String.to_atom(mode))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", %{"url" => url} = _params, socket) when url != "" do
    ascii_result = convert_to_ascii(url)

    {:noreply,
     socket
     |> assign(ascii: ascii_result, filename: url)
     |> put_flash(:info, "Conversion successful for URL: #{url}")}
  end

  def handle_event("submit", _params, socket) do
    case socket.assigns.uploads.file.entries do
      [entry] ->
        file_path =
          consume_uploaded_entry(socket, entry, fn %{path: path} ->
            dest = Path.join("uploads", Path.basename(path))
            File.cp!(path, dest)
            dest
          end)

        ascii_result = convert_to_ascii(file_path)

        {:noreply,
         socket
         |> assign(ascii: ascii_result, filename: entry.client_name)
         |> put_flash(:info, "Conversion successful for File: #{entry.client_name}")}

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
      <Layouts.flash_group flash={@flash} />

      <FileInput.input_form for={@form} mode={@mode} url={@url} uploads={@uploads} />
      
    <!-- ASCII output -->
      <%= if @ascii do %>
        <FileInput.ascii filename={@filename} ascii={@ascii} />
      <% end %>
    </div>
    """
  end
end
