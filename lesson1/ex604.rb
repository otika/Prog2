#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# Header
require 'date'

# 蔵書データ
title = "実装アジャイル ソフトウェア開発法とプロジェクト管理"
author = "山田 正樹"
yomi = "やまだまさき"
publisher = "ソフトリサーチセンター"

pages = 248
price = 2500
tax = 0.05
purchase_price = price * (1 + tax)

publish_date = Date.new(2005, 1, 25)
purchase_date = Date.new(2005, 3, 15)

# 蔵書データの表示
puts "書籍名：\t" + title
puts "著者名：\t" + author
puts "よみがな：\t" + yomi
puts "出版社：\t" + publisher

puts "ページ数:\t" + pages.to_s + "ページ"
puts "販売価格：\t" + price.to_s + "円"
puts "購入費用:\t" + purchase_price.to_s + "円"

puts "出版年:\t" + publish_date.year.to_s
puts "出版月:\t" + publish_date.mon.to_s
puts "購入日:\t" + purchase_date.to_s
