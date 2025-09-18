defmodule AsconvwsWeb.AsconvLive do
  use AsconvwsWeb, :live_view

  @type state :: :done | :converting

  def mount(_params, _session, socket) do
    form = to_form(%{"url" => ""}, as: "input")

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

  def handle_event("submit", %{"input" => params}, socket) do
    case socket.assigns.mode do
      :url -> handle_url(params, socket)
      :file -> handle_file(params, socket)
      _ -> {:noreply, socket}
    end
  end

  def handle_info({"convert", path, name, params}, socket) do
    {result, ascii} = convert_to_ascii(path, params)

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

  def handle_url(params, socket) do
    socket = assign(socket, state: :converting)
    url = params["url"]
    send(self(), {"convert", url, url, params})
    {:noreply, socket}
  end

  def handle_file(params, socket) do
    case socket.assigns.uploads.file.entries do
      [entry] ->
        file_path =
          consume_uploaded_entry(socket, entry, fn %{path: path} ->
            dest = Path.join("uploads", Path.basename(path))
            File.cp!(path, dest)
            dest
          end)

        socket = assign(socket, state: :converting)
        send(self(), {"convert", file_path, entry.client_name, params})
        {:noreply, socket}

      [] ->
        {:noreply, socket}
    end
  end

  defp convert_to_ascii(path, params) do
    # exe = Path.join(:code.priv_dir(:asconvws), "asconv")
    exe = "asconv"

    {out, status} = System.cmd(exe, make_args(path, params))

    case status do
      0 -> {:ok, out}
      _ -> {:error, ""}
    end
  end

  defp make_args(path, params) do
    ["ascii", "-i", path, "-s", params["scale"]]
  end

  def render(assigns) do
    ~H"""
    <div>
      <Layouts.top_bar />
      <Layouts.flash_group flash={@flash} />

      <div class="p-2">
        <Layouts.FileInput.input_form for={@form} mode={@mode} uploads={@uploads} />

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
    </div>
    """
  end
end
