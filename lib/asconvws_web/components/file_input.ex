defmodule AsconvwsWeb.FileInput do
  use AsconvwsWeb, :component

  @doc """
  Renders a toggle between URL input and file input.
  """
  def render(assigns) do
    ~H"""
    <div id={@id || "input-switcher"} class="space-y-4 p-4 border rounded">
      
    <!-- Toggle Switch -->
      <div class="flex items-center space-x-4">
        <span id="label-url" class="font-bold">URL</span>
        <label class="relative inline-flex items-center cursor-pointer">
          <input type="checkbox" id="mode-toggle" class="sr-only" onchange="toggleMode(this)" />
          <div class="w-12 h-6 bg-gray-300 rounded-full shadow-inner transition-colors"></div>
          <div class="dot absolute left-1 top-1 bg-white w-4 h-4 rounded-full shadow transition-transform">
          </div>
        </label>
        <span id="label-file" class="text-gray-500">File</span>
      </div>
      
    <!-- URL Input -->
      <div id="url-input" class="mt-2">
        <label class="block mb-1">Enter URL</label>
        <input
          type="text"
          name="url"
          class="border rounded p-2 w-full"
          placeholder="https://example.com"
        />
      </div>
      
    <!-- File Input with Drag-and-Drop -->
      <div id="file-input" class="mt-2" style="display:none;">
        <label class="block mb-1">Upload File</label>
        <div id="dropzone" class="border-2 border-dashed p-4 text-center rounded cursor-pointer">
          Drag & drop a file here, or click to select.
          <input type="file" name="file" class="hidden" id="file-selector" />
        </div>
        <p id="file-name" class="mt-2 text-gray-700"></p>
      </div>
      
    <!-- JS Toggle + Drag-and-Drop -->
      <script>
        // Toggle between URL / File
        function toggleMode(el) {
          const isFile = el.checked;
          document.getElementById("url-input").style.display = isFile ? "none" : "block";
          document.getElementById("file-input").style.display = isFile ? "block" : "none";
          document.querySelector('input[name="url"]').disabled = isFile;
          document.querySelector('input[name="file"]').disabled = !isFile;

          document.getElementById("label-url").className = isFile ? "text-gray-500" : "font-bold";
          document.getElementById("label-file").className = isFile ? "font-bold" : "text-gray-500";

          const dot = el.nextElementSibling.nextElementSibling;
          dot.style.transform = isFile ? "translateX(24px)" : "translateX(0)";
          el.nextElementSibling.style.backgroundColor = isFile ? "#2563EB" : "#D1D5DB"; 
        }

        // Drag-and-drop file selection
        const dropzone = document.getElementById("dropzone");
        const fileInput = document.getElementById("file-selector");
        const fileNameDisplay = document.getElementById("file-name");

        dropzone.addEventListener("click", () => fileInput.click());

        dropzone.addEventListener("dragover", (e) => {
          e.preventDefault();
          dropzone.classList.add("bg-gray-100");
        });

        dropzone.addEventListener("dragleave", () => {
          dropzone.classList.remove("bg-gray-100");
        });

        dropzone.addEventListener("drop", (e) => {
          e.preventDefault();
          dropzone.classList.remove("bg-gray-100");
          const files = e.dataTransfer.files;
          if (files.length > 0) {
            fileInput.files = files; // assign files to input
            fileNameDisplay.textContent = files[0].name;
          }
        });

        fileInput.addEventListener("change", () => {
          if (fileInput.files.length > 0) {
            fileNameDisplay.textContent = fileInput.files[0].name;
          } else {
            fileNameDisplay.textContent = "";
          }
        });
      </script>
    </div>
    """
  end

  attr :filename, :string, required: true
  attr :ascii, :string, required: true

  def ascii(assigns) do
    ~H"""
    <div class="mt-6">
      <h2 class="font-bold mb-2">ASCII: {@filename}</h2>
      <pre class="bg-black font-mono text-xs leading-tight p-4 overflow-auto whitespace-pre">
        {@ascii}
          </pre>
    </div>
    """
  end
end
