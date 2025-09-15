defmodule AsconvwsWeb.FileInput do
  use AsconvwsWeb, :component

  @doc """
  Renders a toggle between URL input and file input.
  """

  attr :mode, :string, required: true
  attr :url, :string, required: true
  attr :uploads, :any, required: true
  attr :for, :any, required: true

  def input_form(assigns) do
    ~H"""
    <div>
      <div class="flex items-center space-x-4">
        <span class={"font-bold #{if @mode == :url, do: "text-black", else: "text-gray-500"}"}>
          URL
        </span>

        <label class="relative inline-flex items-center cursor-pointer">
          <input
            type="checkbox"
            class="sr-only"
            phx-click="toggle_mode"
            phx-value-mode={if @mode == :url, do: "file", else: "url"}
          />
          <div class={"w-12 h-6 bg-gray-300 rounded-full shadow-inner transition-colors #{if @mode == :file, do: "bg-blue-600"}"}>
          </div>
          <div class={"dot absolute left-1 top-1 bg-white w-4 h-4 rounded-full shadow transition-transform #{if @mode == :file, do: "translate-x-6"}"}>
          </div>
        </label>

        <span class={"font-bold #{if @mode == :file, do: "text-black", else: "text-gray-500"}"}>
          File
        </span>
      </div>
      
    <!-- Form -->
      <.form for={@for} phx-submit="submit" phx-change="validate" multipart={@mode == :file}>
        <%= if @mode == :url do %>
          <input
            type="text"
            name="url"
            value={@url}
            placeholder="https://example.com/image.png"
            class="w-full border rounded px-2 py-1"
          />
        <% else %>
          <div phx-drop-target={@uploads.file.ref}>
            <.live_file_input upload={@uploads.file} />
          </div>
        <% end %>

        <.button type="submit" class="mt-2 bg-blue-600 text-white px-4 py-2 rounded">
          Submit
        </.button>
      </.form>
    </div>
    """
  end

  attr :filename, :string, required: true
  attr :ascii, :string, required: true

  def ascii(assigns) do
    ~H"""
    <div class="mt-6">
      <h2 class="font-bold mb-2">ASCII: {@filename}</h2>
      <pre class="bg-black font-mono text-xs p-4 overflow-auto">{@ascii}</pre>
    </div>
    """
  end
end
