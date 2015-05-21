#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# Header
require 'date'

# 蔵書データ
# 蔵書データのデータ構造
=begin
book_hoge =
[
  title,
  author,
  yomi,
  publisher,
  page,
  price,
  purchase_price,
  isbn_10,
  isbn_13,
  size,
  publish_date,
  purchase_date,
]
=end

# 配列アクセス
TITLE = 0
AUTHOR = 1
YOMI = 2
PUBLISHER = 3
PAGE = 4
PRICE = 5
PURCHASE_PRICE = 6
ISBN_10 = 7
ISBN_13 = 8
SIZE = 9
PUBLISH_DATE  = 10
PURCHASE_DATE = 11

# "実装アジャイル ソフトウェア開発法とプロジェクト管理"の書籍データ
book_agile_software_development_and_manage_projects =
[
  "実装アジャイル ソフトウェア開発法とプロジェクト管理",
  "山田 正樹",
  "やまだまさき",
  "ソフトリサーチセンター",
  248,
  2500,
  2650,
  "4883732088",
  "978-4883732081",
  "21 x 14.8 x 2",
  Date.new(2005,1,25),
  Date.new(2005, 2, 2),
]

book_lego_mindstorms_nxt =
[
  "入門LEGO　MINDSTORMS NXT　レゴブロックで作る動くロボット",
  "大庭　慎一郎",
  "おおばしんいちろう",
  "ソフトバンククリエイティブ",
  164,
  2400,
  2520,
  "4797338253",
  "978-4797338256",
  "23 x 18.2 x 1.6",
  Date.new(2006,12,23),
  Date.new(2007, 1, 10),
]

# 表示部簡略化のためArrayに格納
books =
[
  book_agile_software_development_and_manage_projects,
  book_lego_mindstorms_nxt,
]

# 蔵書データの表示
# eachメソッドでコード削減
books.each { |b|
  puts "書籍名：\t"   + b[TITLE]
  puts "著者名：\t"   + b[AUTHOR]
  puts "よみがな：\t"  + b[YOMI]
  puts "出版社：\t"   + b[PUBLISHER]

  puts "ページ数:\t" + b[PAGE].to_s + "ページ"
  puts "販売価格：\t" + b[PRICE].to_s + "円"
  puts "購入費用:\t" + b[PURCHASE_PRICE].to_s + "円"

  puts "ISBN_10:\t" + b[ISBN_10]
  puts "ISBN_13:\t" + b[ISBN_13]
  puts "寸法:\t"    + b[SIZE]

  puts "出版年:\t" + b[PUBLISH_DATE].year.to_s
  puts "出版月:\t" + b[PUBLISH_DATE].mon.to_s
  puts "購入日:\t" + b[PURCHASE_DATE].to_s
  puts
}
