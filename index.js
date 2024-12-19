const imports = { imports: { log: arg => log(arg) } };

const consoleDiv = document.getElementById('console');

function log(message) {
  const newLine = document.createElement('div');
  newLine.textContent = message;
  consoleDiv.appendChild(newLine);
  consoleDiv.scrollTop = consoleDiv.scrollHeight; // Auto-scroll to bottom
}

// Fetch the WebAssembly file
fetch('index.wasm')
    .then(response => response.arrayBuffer()) // Get the binary data
    .then(bytes => WebAssembly.instantiate(bytes, imports)) // Instantiate the WebAssembly module
    .then(result => {
        // The WebAssembly instance is available in `result.instance`
        console.log("WASM Module Loaded:", result.instance);

      // Call an exported function (if any)
      result.instance.exports.START();
    })
    .catch(err => {
        console.error("Error loading WASM file:", err);
    });
