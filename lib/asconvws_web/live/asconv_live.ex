defmodule AsconvwsWeb.AsconvLive do
  use AsconvwsWeb, :live_view

  @type state :: :done | :converting

  def mount(_params, _session, socket) do
    form = to_form(%{}, as: "input")

    {:ok,
     socket
     |> assign(form: form, mode: :url, ascii: nil, filename: nil, url: "", state: :done)
     |> allow_upload(:file, accept: ~w(.png .jpg .jpeg .gif), max_entries: 1)}
  end

  def handle_event("toggle_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, mode: String.to_atom(mode))}
  end

  def handle_event("copy_to_clipboard", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Copied to clipboard")}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", %{"url" => url} = _params, socket) when url != "" do
    socket = assign(socket, state: :converting)
    send(self(), {"convert", url, url})
    {:noreply, socket}
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

        socket = assign(socket, state: :converting)
        send(self(), {"convert", file_path, entry.client_name})
        {:noreply, socket}

      [] ->
        {:noreply, socket}
    end
  end

  def handle_info({"convert", path, name}, socket) do
    {result, ascii} = convert_to_ascii(path)

    case result do
      :ok ->
        {:noreply,
         socket
         |> assign(ascii: ascii, filename: name, state: :done)
         |> put_flash(:info, "Conversion successful")}

      _ ->
        {:noreply,
         socket
         |> assign(ascii: "", filename: "", state: :done)
         |> put_flash(:error, "Conversion failed")}
    end
  end

  defp convert_to_ascii(path) do
    # exe = Path.join(:code.priv_dir(:asconvws), "asconv")
    exe = "asconv"

    {out, status} = System.cmd(exe, ["ascii", "-i", path, "-s", "0.1"])

    case status do
      0 -> {:ok, out}
      _ -> {:error, ""}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <Layouts.top_bar />
      <Layouts.flash_group flash={@flash} />

      <Layouts.FileInput.input_form for={@form} mode={@mode} url={@url} uploads={@uploads} />
      <%= if @state == :converting do %>
        <div class="flex items-center">
          <Layouts.FileInput.spinner />
          <p>Converting image..</p>
        </div>
      <% end %>
      
    <!-- ASCII output -->
      <%= if @ascii do %>
        <Layouts.FileInput.ascii filename={@filename} ascii={@ascii} />
      <% end %>
    </div>
    """
  end
end
