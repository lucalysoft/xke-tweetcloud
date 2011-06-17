#!/usr/bin/python
import os
import sys
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import urlparse
import logging
import time

PORT = 8080
'''
$ curl -i -uuser:password http://stream.twitter.com/1/statuses/sample.json
HTTP/1.1 200 OK
Content-Type: application/json
Transfer-Encoding: chunked
Server: Jetty(6.1.25)
'''
def sampleFilename(idx):
    return os.path.join(os.path.dirname(sys.argv[0]), 'sample%i.json' % idx)

class StreamAPIServer(BaseHTTPRequestHandler):

    def do_GET(self):
        self.send_response(200)
        self.send_header ('Content-Type', 'application/json')
        #self.send_header ('Transfer-Encoding', 'chunked')
        self.end_headers()
        dataLines = file(sampleFilename(1)).read().split("\n")
        dataLines.extend(file(sampleFilename(2)).read().split("\n"))
        dataLines.extend(file(sampleFilename(3)).read().split("\n"))
        while "" in dataLines:
            dataLines.remove("")
        while True:
            for line in dataLines:
                time.sleep(0.01)
                self.wfile.write(line + "\n")
                self.wfile.flush()
        

def main():
    logging.basicConfig(level=logging.DEBUG)

    try:
        logging.info('Starting server on port %i' % PORT)
        server = HTTPServer(('', PORT), StreamAPIServer)
        server.serve_forever()
    except KeyboardInterrupt:
        print '^C received, shutting down server'
        server.socket.close()

if __name__ == '__main__':
    main()
