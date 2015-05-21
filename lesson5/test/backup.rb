#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

filename = ARGV[0].to_s

if !File.exist?(filename)
  puts "指定するファイルが存在しません"
  exit 1
end

extension = 1
loop do
  backupname = "#{filename}.#{extension.to_s}"
  if !(File.exist? backupname)
    open(filename, "r"){ |infile|
      open(backupname, "w"){ |outfile|
        outfile.print infile.read
      }
    }
    puts "backup #{filename} -> #{backupname}"
    break
  end
  extension += 1
end
