import os, random
from http.server import BaseHTTPRequestHandler, HTTPServer

VERSION = os.getenv("APP_VERSION", "v1")
ERROR_RATE = float(os.getenv("ERROR_RATE", "0"))
REGION = os.getenv("REGION", "unknown")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/healthz":
            return self._send(200, "ok")
        if random.random() < ERROR_RATE:
            return self._send(500, "error")
        self._send(200, f"version={VERSION} region={REGION}\n")

    def _send(self, code, body):
        data = body.encode()
        self.send_response(code)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def log_message(self, *args):
        pass

HTTPServer(("", 8080), Handler).serve_forever()
