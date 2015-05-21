#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'date'

load "BookInfoManager.rb"

# アプリケーションのインスタンス生成とセットアップ
book_info_manager = BookInfoManager.new

# アプリケーション開始
begin
  book_info_manager.run
rescue Interrupt
  puts "\nプログラムが終了しました"
rescue
  puts "\n不正終了です"
end
