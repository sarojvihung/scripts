#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import json


class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        json_str = json.dumps({"started": "yes"})
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json_str.encode(encoding='utf_8'))

    def do_HEAD(self):
        self._set_headers()

    def do_POST(self):
        self.data_string = self.rfile.read(int(self.headers['Content-Length']))

        data = json.loads(self.data_string)
        numSession = data['numSessions']
        cmd = "nr-ue -c /opt/UERANSIM/config/open5gs/ue.yaml -n {} > /opt/UERANSIM/config/open5gs/uesim.logs 2>&1 &".format(
            numSession)
        os.system(cmd)

        json_str = json.dumps({"started": "yes"})
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.end_headers()
        self.wfile.write(json_str.encode(encoding='utf_8'))

        return


def run(server_class=HTTPServer, handler_class=S, port=80):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting httpd...')
    httpd.serve_forever()


if __name__ == "__main__":
    from sys import argv

if len(argv) == 2:
    run(port=int(argv[1]))
else:
    run()
