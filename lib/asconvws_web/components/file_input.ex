defmodule AsconvwsWeb.Layouts.FileInput do
  use AsconvwsWeb, :component

  @doc """
  Renders a toggle between URL input and file input.
  """

  attr :mode, :string, required: true

  def mode_toggle(assigns) do
    ~H"""
    <div id="mode-toggle" class="flex items-center space-x-4 p-1">
      <span class={"font-bold #{if @mode == :url, do: "text-accent", else: "text-gray-500"}"}>
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
        <div class={"w-12 h-6 rounded-full shadow-inner transition-colors #{if @mode == :file, do: "bg-accent", else: "bg-gray-300 "}"}>
        </div>
        <div class={"dot absolute left-1 w-4 h-4 rounded-full shadow transition-transform #{if @mode == :file, do: "translate-x-6 bg-white ", else: "bg-accent"}"}>
        </div>
      </label>

      <span class={"font-bold #{if @mode == :file, do: "text-accent", else: "text-gray-500"}"}>
        File
      </span>
    </div>
    """
  end

  attr :mode, :string, required: true
  attr :uploads, :any, required: true
  attr :edge_algs, :any, required: true
  attr :for, :any, required: true

  def input_form(assigns) do
    ~H"""
    <div class="p-2 max-w-150">
      <.mode_toggle mode={@mode} />
      
    <!-- Form -->
      <.form
        :let={f}
        for={@for}
        phx-submit="submit"
        phx-change="validate"
        multipart={@mode == :file}
        class="space-y-2"
      >
        <%= if @mode == :url do %>
          <.input
            type="text"
            label="Url:"
            field={f[:url]}
            placeholder="https://example.com/image.png"
            class="w-full border rounded px-2 py-1"
          />
        <% else %>
          <div
            phx-drop-target={@uploads.file.ref}
            class="relative border-2 border-dashed border-gray-300 rounded p-4 hover:border-accent transition-colors"
          >
            <p class="text-center text-gray-500">
              <%= if @uploads.file.entries != [] do %>
                {List.first(@uploads.file.entries).client_name}
              <% else %>
                Drag and drop or click to select a file
              <% end %>
            </p>
            <.live_file_input
              upload={@uploads.file}
              class="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
            />
          </div>
        <% end %>

        <div class="flex items-center space-x-4">
          <.input
            field={f[:width]}
            label="Width:"
            type="number"
            placeholder="default"
            min="0"
            step="10"
            class="w-25 border rounded px-2 py-1"
          />
          <.input
            field={f[:height]}
            label="Height:"
            type="number"
            placeholder="default"
            min="0"
            step="10"
            class="w-25 border rounded px-2 py-1"
          />
        </div>

        <.input
          field={f[:scale]}
          label="Scale:"
          type="number"
          min="0"
          step="0.05"
          class="w-20 border rounded px-2 py-1"
        />
        <.input
          field={f[:brightness]}
          label="Brightness:"
          type="number"
          min="0"
          step="0.05"
          class="w-20 border rounded px-2 py-1"
        />

        <div class="flex items-center space-x-4">
          <.input
            field={f[:edges]}
            label="Edge detection"
            type="checkbox"
            class="mb-0 checkbox checkbox-sm text-accent"
          />
          <%= if @for.params["edges"] == "true" do %>
            <.input
              field={f[:edge_alg]}
              label="Algorithm:"
              type="select"
              options={@edge_algs}
              class="w-40 px-2 select"
            />
          <% end %>
        </div>

        <.input
          field={f[:invert]}
          label="Invert charset"
          type="checkbox"
          class="mb-0 checkbox checkbox-sm text-accent"
        />

        <.button
          type="submit"
          data-ripple-light="true"
          variant="primary"
        >
          Submit
        </.button>
      </.form>
    </div>
    """
  end

  attr :filename, :string, required: true
  attr :fit, :atom, required: true
  attr :ascii, :string, required: true

  def ascii(assigns) do
    ~H"""
    <div class="mt-6">
      <div class="flex justify-between items-center">
        <h2 class="font-bold mb-2">Input: {@filename}</h2>

        <div class="flex justify-between items-center space-x-10 mb-2">
          <label class="inline-flex items-center cursor-pointer space-x-2">
            <span class="ms-3 text-sm font-medium">
              Fit
            </span>
            <.input
              type="checkbox_bare"
              label="Fit"
              name="fit"
              checked={@fit}
              phx-click="toggle_fit"
              class="toggle toggle-primary"
            />
          </label>

          <.button
            phx-hook="CopyToClipboard"
            phx-update="ignore"
            phx-click="copy_to_clipboard"
            data-to="ascii-content"
            id="copy-clipboard"
            data-ripple-light="true"
            variant="primary"
          >
            Copy to Clipboard
          </.button>
        </div>
      </div>
      <pre
        id="ascii-content"
        phx-hook="FitAscii"
        data-fit={if @fit, do: "true", else: "false"}
        class="bg-black font-mono p-4 overflow-auto text-sm text-neutral-50"
      >{@ascii}</pre>
    </div>
    """
  end

  def spinner(assigns) do
    ~H"""
    <span class="loading loading-spinner loading-sm text-accent"></span>
    """
  end
end
