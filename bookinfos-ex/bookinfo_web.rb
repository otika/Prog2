#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'webrick'
require 'erb'
require 'rubygems'
require 'dbi'

class String
  alias_method(:orig_concat, :concat)
  def concat(value)
    if RUBY_VERSION > "1.9"
      orig_concat value.force_encoding('UTF-8')
    else
      orig_concat value
    end
  end
end

# port 50917
config = {
  :Port => 50917,
  :DocumentRoot => '.',
}

# erbハンドラを有効にしたサーバーのインスタンスを生成
WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
server = WEBrick::HTTPServer.new(config)
server.config[:MimeTypes]["erb"] = "text/html"

# 一覧表示を定義
server.mount_proc("/list") { |req, res|
  p req.query
  puts req.query['operation']
  if /(.*)\.(delete|edit)$/ =~ req.query['operation']
    target_id = $1
    operation = $2
    if operation == 'delete'
      template = ERB.new( File.read('delete.erb'))
    elsif operation == 'edit'
      template = ERB.new( File.read('edit.erb'))
    end
    res.body << template.result( binding )
  else
    puts "noselected"
    template = ERB.new( File.read('noselected.erb'))
    res.body << template.result( binding )
  end
}

# データ登録を定義
server.mount_proc("/entry") { |req, res|
  p req.query

  begin
    dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
    dbh['AutoCommit']=false
    dbh.transaction do
      rows = dbh.select_one("select * from bookinfos where id='#{req.query['id']}';")
      if rows then

        template = ERB.new( File.read('noentried.erb'))
        res.body << template.result( binding)
      else
        dbh.do("insert into bookinfos \
        values('#{req.query['id']}', '#{req.query['title']}', '#{req.query['author']}',\
        '#{req.query['yomi']}', '#{req.query['publisher']}', '#{req.query['page']}',\
        '#{req.query['price']}', '#{req.query['purchase_price']}','#{req.query['isbn_10']}',\
        '#{req.query['isbn_13']}', '#{req.query['size']}',\
        '#{req.query['publish_date']}', '#{req.query['purchase_date']}',\
        '#{req.query['purchase_reason']}', '#{req.query['notes']}');")

        template = ERB.new( File.read('entried.erb'))
        res.body << template.result( binding )
        puts "entried"
      end
    end
  rescue => e
    p e
  ensure
    dbh.disconnect if dbh!=nil
  end
}

# データ検索を定義
server.mount_proc("/retrieve"){ |req,res|
  p req.query
  a = ['id', 'title', 'author', 'yomi', 'publisher', 'page', 'price', 'purchase_price', 'isbn_10', 'isbn_13', 'size', 'publish_date','purchase_date', 'purchase_reason', 'notes']
  # 検索対象に含まれない要素を消す
  a.delete_if{|name| req.query[name] == ""}
  # SQLインジェクション対策追加

  # 検索対象が無い場合,where句を使わない
  if a.empty?
    where_date=""
  else
    a.map! {|name| "#{name}='#{req.query[name]}'"}
    where_date = "where " + a.join(' or ')
  end
  a="booooooooooook"
  template = ERB.new( File.read('retrieved.erb'))
  res.body << template.result( binding)
}

# データ修正を定義
server.mount_proc("/edit") { |req, res|
  p req.query
  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh.do("update bookinfos set id='#{req.query['id']}', title='#{req.query['title']}',\
  author='#{req.query['author']}', yomi='#{req.query['yomi']}', publisher='#{req.query['publisher']}',\
  page='#{req.query['page']}', price='#{req.query['price']}', purchase_price='#{req.query['purchase_price']}',\
  isbn_10='#{req.query['isbn_10']}', isbn_13='#{req.query['isbn_13']}', size='#{req.query['size']}', \
  publish_date='#{req.query['publish_date']}', purchase_date='#{req.query['purchase_date']}',\
  purchase_reason='#{req.query['purchase_reason']}', notes='#{req.query['notes']}'\
  where id='#{req.query['prev_id']}';")
  dbh.disconnect
  template = ERB.new(File.read('edited.erb'))
  res.body << template.result(binding)
}

# データ削除を定義
server.mount_proc("/delete") { |req, res|
  p req.query
  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh.do("delete from bookinfos where id='#{req.query['id']}';")
  dbh.do("delete from bookinfos where id='#{req.query['id']}';")
  dbh.disconnect
  template = ERB.new( File.read('deleted.erb'))
  res.body << template.result( binding)
}

# シグナルをトラップ
trap(:INT) do
  server.shutdown
end
# サーバー起動
server.start
