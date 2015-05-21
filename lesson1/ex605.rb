#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# Header
require 'date'

# 蔵書データ
titles = [
  "実装アジャイル ソフトウェア開発法とプロジェクト管理",
  "入門LEGO　MINDSTORMA NXT　レゴブロックで作る動くロボット",
]

authors = [
  "山田 正樹",
  "大庭　慎一郎",
]

yomies = [
  "やまだまさき",
  "おおばしんいちろう"
]

publishers = [
  "ソフトリサーチセンター",
  "ソフトバンククリエイティブ",
]

pages =  [
  248,
  164,
]

prices = [
  2500,
  2400
]

purchase_prices = [
  2650,
  2520,
]

publish_dates = [
  Date.new(2005, 1, 25),
  Date.new(2006, 12, 23),
]

purchase_dates =
[
  Date.new(2005, 2, 2),
  Date.new(2007, 1, 10),
]



# 蔵書データの表示
titles.size.times { |i|
puts "書籍名：\t" + titles[i]
puts "著者名：\t" + authors[i]
puts "よみがな：\t" + yomies[i]
puts "出版社：\t" + publishers[i]

puts "ページ数:\t" + pages[i].to_s + "ページ"
puts "販売価格：\t" + prices[i].to_s + "円"
puts "購入費用:\t" + purchase_prices[i].to_s + "円"

puts "出版年:\t" + publish_dates[i].year.to_s
puts "出版月:\t" + publish_dates[i].mon.to_s
puts "購入日:\t" + purchase_dates[i].to_s
}
