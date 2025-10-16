defmodule AsconvwsWeb.AsconvLive do
  use AsconvwsWeb, :live_view

  @type state :: :done | :converting
  @edge_algs [
    %{name: "Sobel", id: "1"},
    %{name: "DoG", id: "2"},
    %{name: "LoG", id: "3"}
  ]
  @edge_algs_options Enum.map(@edge_algs, fn %{name: name, id: id} -> {name, id} end)

  def mount(_params, _session, socket) do
    form =
      to_form(
        %{
          "url" => "",
          "scale" => 1,
          "width" => "",
          "height" => "",
          "brightness" => 1,
          "invert" => "false",
          "edges" => "false",
          "edge_alg" => 1
        },
        as: "input"
      )

    {:ok,
     socket
     |> assign(
       form: form,
       mode: :url,
       ascii: nil,
       filename: nil,
       url: "",
       state: :done,
       edge_algs: @edge_algs_options,
       fit_to_window: false
     )
     |> allow_upload(:file, accept: ~w(.png .jpg .jpeg .gif), max_entries: 1)}
  end

  def handle_event("toggle_mode", %{"mode" => mode}, socket) do
    {:noreply, socket |> assign(mode: String.to_atom(mode))}
  end

  def handle_event("toggle_fit", %{"value" => "true"}, socket) do
    {:noreply, assign(socket, fit_to_window: true)}
  end

  def handle_event("toggle_fit", _params, socket) do
    {:noreply, assign(socket, fit_to_window: false)}
  end

  def handle_event("copy_to_clipboard", _params, socket) do
    {:noreply, socket |> put_flash(:info, "Copied to clipboard")}
  end

  def handle_event("validate", %{"input" => input}, socket) do
    {:noreply, assign(socket, :form, to_form(input, as: "input"))}
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
    url = params["url"]

    case url do
      "" ->
        {:noreply, socket}

      _ ->
        socket = assign(socket, state: :converting)
        send(self(), {"convert", url, url, params})
        {:noreply, socket}
    end
  end

  def handle_file(params, socket) do
    case socket.assigns.uploads.file.entries do
      [entry] ->
        file_path =
          consume_uploaded_entry(socket, entry, fn %{path: path} ->
            dest = Path.join("uploads", Path.basename(path))
            File.cp!(path, dest)
            {:postpone, dest}
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

  def get_alg_name(id) do
    case Enum.find(@edge_algs, fn %{id: eid} -> eid == id end) do
      %{name: name} -> name
      nil -> nil
    end
  end

  defp make_args(path, params) do
    ["ascii", "-i", path, "-s", params["scale"], "-b", params["brightness"]]
    |> Enum.concat(
      case Integer.parse(params["width"]) do
        {width, ""} when width > 0 -> ["-W", Integer.to_string(width)]
        _ -> []
      end
    )
    |> Enum.concat(
      case Integer.parse(params["height"]) do
        {height, ""} when height > 0 -> ["-H", Integer.to_string(height)]
        _ -> []
      end
    )
    |> Enum.concat(if params["invert"] == "true", do: ["-r"], else: [])
    |> Enum.concat(
      if params["edges"] == "true", do: ["-e", get_alg_name(params["edge_alg"])], else: []
    )
  end

  def render(assigns) do
    ~H"""
    <div>
      <Layouts.top_bar />
      <Layouts.flash_group flash={@flash} />

      <div class="p-2">
        <Layouts.FileInput.input_form
          for={@form}
          mode={@mode}
          uploads={@uploads}
          edge_algs={@edge_algs}
        />

        <%= if @state == :converting do %>
          <div class="flex items-center space-x-2">
            <Layouts.FileInput.spinner />
            <p>Converting image..</p>
          </div>
        <% end %>
        
    <!-- ASCII output -->
        <%= if @ascii do %>
          <Layouts.FileInput.ascii filename={@filename} fit={@fit_to_window} ascii={@ascii} />
        <% end %>
      </div>
    </div>
    """
  end
end
