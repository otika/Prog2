#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# 新しいハッシュを作る
str = "Twinkle, twinkle, little star,
How I wonder what you are.
Up above the world so high,
Like a diamond in the sky,
Twinkle, twinkle little star,
How I wonder what you are."

# 上の単語を行ごと分割し、linesという行列に格納する
lines = str.split(/\n/)

# "you"にマッチする行を表示する
puts "youが含まれていた行"
lines.each { |line|
  if line =~ /[Yy]ou/ then
    puts line
  end
}

puts

# 行末に","がきている行を表示する
puts "行末にカンマが含まれていた行"
lines.each { |line|
  if line =~ /,$/ then
    puts line
  end
}

puts

# "i"が来て2文字おいてlがくる文字列が含まれる
puts '"i"が来て2文字おいてlがくる文字列が含まれる行'
lines.each { |line|
  if line =~ /i..l/ then
    puts lines
  end
}
