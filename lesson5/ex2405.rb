#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'webrick'

# port 50917
config = {
  :Port => 8099,
  :DocumentRoot => '.',
}

WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)

server = WEBrick::HTTPServer.new(config)

server.config[:MimeTypes]["erb"] = "text/html"

server.mount_proc("/testprog") {|req,res|
  res.body << "<html><body><p>アクセスした日付は#{Date.today.to_s}です。</p>"
  res.body << "<p>リクエストのパスは#{req.path}でした。</p>"

  res.body << "<ul>"
  req.each { |key, value|
    res.body << "<li>#{key} : #{value}</li>"
  }
  res.body << "</ul>"
  res.body << "</body></html>"
}

trap(:INT) do
  server.shutdown
end

server.start
