#!/usr/bin/python3
#from http.server import HTTPServer, BaseHTTPRequestHandler
import http.server
import socketserver
import BaseHTTPRequestHandler

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Hello, world! This site can't be reached fo later")


httpd = HTTPServer(('localhost', 8000), SimpleHTTPRequestHandler)
httpd.serve_forever()
