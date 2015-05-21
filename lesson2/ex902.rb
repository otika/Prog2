#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# 新しいハッシュを作る
friends = {
  :shin => "Shin Kuboaki",
  :shinchirou => "Shinichirou Ooba",
  :shinfo => "Shingo Katori"
}

# ハッシュの要素をひとつずつ処理する
# 繰り返しの都度、キーと値をブロック内のローカル変数key, valueに渡す
friends.each_key{ |key|
  # ローカル変数の値を表示する
  puts "#{key}"
}
