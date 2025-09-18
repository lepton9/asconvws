defmodule AsconvwsWeb.Layouts.FileInput do
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
    <div class="p-2 w-150">
      <div id="mode-toggle" class="flex items-center space-x-4 p-1">
        <span class={"font-bold #{if @mode == :url, do: "text-black", else: "text-gray-500"}"}>
          URL
        </span>

        <label class="relative inline-flex items-center cursor-pointer">
          <.input
            type="checkbox"
            name="mode"
            class="sr-only"
            phx-click="toggle_mode"
            phx-value-mode={if @mode == :url, do: "file", else: "url"}
          />
          <div class={"w-12 h-6 bg-gray-300 rounded-full shadow-inner transition-colors #{if @mode == :file, do: "bg-blue-600"}"}>
          </div>
          <div class={"dot absolute left-1 bg-white w-4 h-4 rounded-full shadow transition-transform #{if @mode == :file, do: "translate-x-6"}"}>
          </div>
        </label>

        <span class={"font-bold #{if @mode == :file, do: "text-black", else: "text-gray-500"}"}>
          File
        </span>
      </div>
      
    <!-- Form -->
      <.form for={@for} phx-submit="submit" phx-change="validate" multipart={@mode == :file}>
        <%= if @mode == :url do %>
          <.input
            type="text"
            name="url"
            value={@url}
            placeholder="https://example.com/image.png"
            class="w-full border rounded px-2 py-1"
          />
        <% else %>
          <div
            phx-drop-target={@uploads.file.ref}
            class="relative border-2 border-dashed border-gray-300 rounded p-4 hover:border-blue-600 transition-colors"
          >
            <p class="text-center text-gray-500">
              <%= if @uploads.file.entries != [] do %>
                {List.first(@uploads.file.entries).client_name}
              <% else %>
                Drag and drop a file here, or click to select a file
              <% end %>
            </p>
            <.live_file_input
              upload={@uploads.file}
              class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            />
          </div>
        <% end %>

        <.button
          type="submit"
          data-ripple-light="true"
          class="mt-2 bg-gradient-to-r from-blue-500 via-blue-600 to-blue-700 hover:bg-gradient-to-br transition-all shadow-md disabled:pointer-events-none disabled:opacity-50 disabled:shadow-none px-4 py-2 rounded"
        >
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
      <div class="flex justify-between items-center">
        <h2 class="font-bold mb-2">ASCII: {@filename}</h2>
        <button
          class="mt-2 bg-blue-600 text-white px-4 py-2 rounded"
          phx-hook="CopyToClipboard"
          phx-update="ignore"
          phx-click="copy_to_clipboard"
          data-to="ascii-content"
          id="copy-clipboard"
        >
          Copy to Clipboard
        </button>
      </div>
      <pre class="bg-black font-mono text-xs p-4 overflow-auto" id="ascii-content">{@ascii}</pre>
    </div>
    """
  end
end
