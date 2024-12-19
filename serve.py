import sys
import os
from http.server import SimpleHTTPRequestHandler
from socketserver import TCPServer

class CustomHTTPRequestHandler(SimpleHTTPRequestHandler):
    """Custom handler to modify index.js before serving."""
    
    def do_GET(self):
        """Override the GET request to modify index.js before serving it."""
        print(f"Handling request for: {self.path}")  # Debugging log
        if self.path == '/index.js':
            try:
                # Read the original index.js file
                with open('index.js', 'r') as file:
                    content = file.read()

                # Replace the placeholder with the provided number from the command-line argument
                placeholder = "<number>"
                content = content.replace("index.wasm", os.sys.argv[1] + ".wasm")

                # Send the modified content as the response
                self.send_response(200)
                self.send_header('Content-Type', 'application/javascript')
                self.end_headers()
                self.wfile.write(content.encode('utf-8'))
                print("Served modified index.js.")  # Debugging log
            except Exception as e:
                print(f"Error while handling index.js: {e}")
                self.send_response(500)
                self.end_headers()
        else:
            # Default behavior for other files (e.g., index.html, index.css)
            super().do_GET()

def start_server(directory):
    """Start a simple HTTP server with the custom request handler."""
    os.chdir(directory)  # Change working directory to serve files from here
    handler = CustomHTTPRequestHandler
    httpd = TCPServer(("", 8000), handler)  # Serve on port 8000
    print("Serving at http://localhost:8000")
    httpd.serve_forever()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python serve.py <number>")
        sys.exit(1)

    # Start serving the website locally
    start_server(".")
