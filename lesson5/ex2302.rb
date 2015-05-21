#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'webrick'

config = {
  :Port => 8099,
  :DocumentRoot => '.',
}

s = WEBrick::HTTPServer.new(config)

trap(:INT) do
  s.shutdown
end
s.start
