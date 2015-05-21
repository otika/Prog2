#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# 蔵書データ
title = "実装アジャイル ソフトウェア開発法とプロジェクト管理"
author = "山田 正樹"
yomi = "やまだまさき"
publisher = "ソフトリサーチセンター"

pages = 248
price = 2500
tax = 0.05
purchase_price = price * (1 + tax)

# 蔵書データの表示
puts "書籍名：\t" + title
puts "著者名：\t" + author
puts "よみがな：\t" + yomi
puts "出版社：\t" + publisher

puts "ページ数:\t" + pages.to_s + "ページ"
puts "販売価格：\t" + price.to_s + "円"
puts "購入費用:\t" + purchase_price.to_s + "円"
