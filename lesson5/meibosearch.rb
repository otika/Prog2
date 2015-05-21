#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

print "検索パターン:"
pattern = STDIN.gets.chomp
regexp = Regexp.new(pattern, nil, "u")

while line = gets
  if regexp =~ line
    puts line
  end
end
