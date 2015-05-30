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
      dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
      if nil != dbh.select_one("select id from bookinfos where id='#{target_id.gsub(/'/,"''").gsub(/\0/,"")}';")
        template = ERB.new( File.read('delete.erb'))
      else
        template = ERB.new( File.read('notfound.erb'))
      end
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
  templateMsg1 = "Error"
  templateMsg2 = ""
  template = ERB.new(File.read('empty.erb'))

  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh['AutoCommit']=false
  begin
    # 不整合発生要因とならない
    rows = dbh.select_one("select * from bookinfos where id='#{req.query['id'].gsub(/'/,"''").gsub(/\0/,"")}';")
    # IDが指定されていることを確認
    if req.query['id'] == ''
      templateMsg1 = "蔵書データの登録"
      templateMsg2 = "IDを入力してください"
      puts "id empty"
    # 半角スペースにマッチ
    elsif req.query['id'] =~ / /
      templateMsg1 = "蔵書データの登録"
      templateMsg2 = "IDに半角スペースを含めないでください"
      puts "id include space(half)"
    #elsif !(checkQueryDate(req.query))
    #  puts "query date nogood"

    # データチェックPASS
    else
      dbh.transaction do
        if rows then
          template = ERB.new( File.read('noentried.erb'))
        else
          dbh.do("insert into bookinfos \
          values('#{req.query['id'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['title'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['author'].gsub(/'/,"''").gsub(/\0/,"")}',\
          '#{req.query['yomi'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['publisher'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['page'].gsub(/'/,"''").gsub(/\0/,"")}',\
          '#{req.query['price'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['purchase_price'].gsub(/'/,"''").gsub(/\0/,"")}',\
          '#{req.query['isbn_10'].gsub(/'/,"''").gsub(/\0/,"")}',\
          '#{req.query['isbn_13'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['size'].gsub(/'/,"''").gsub(/\0/,"")}',\
          '#{req.query['publish_date'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['purchase_date'].gsub(/'/,"''").gsub(/\0/,"")}',\
          '#{req.query['purchase_reason'].gsub(/'/,"''").gsub(/\0/,"")}', \
          '#{req.query['notes'].gsub(/'/,"''").gsub(/\0/,"")}');")
          template = ERB.new( File.read('entried.erb'))
          puts "entried"
        end
      end
    end
  rescue => e
    p e
    puts "SQLite3:rollback"
    template = ERB.new( File.read( 'sqlerror.erb'))
  ensure
    res.body << template.result( binding )
  end
  dbh.disconnect if dbh!=nil
}

# データ検索を定義
server.mount_proc("/retrieve"){ |req,res|
  p req.query
  a = ['id', 'title', 'author', 'yomi', 'publisher', 'page', 'price', 'purchase_price', 'isbn_10', 'isbn_13', 'size', 'publish_date','purchase_date', 'purchase_reason', 'notes']
  # 検索対象に含まれない要素を消す
  a.delete_if{|name| req.query[name] == ""}

  # 検索対象が無い場合,where句を使わない
  if a.empty?
    where_date=""
  else
    a.map! {|name| "#{name}='#{req.query[name].gsub(/'/,"''").gsub(/\0/,"")}'"}
    where_date = "where " + a.join(' or ')
  end
  template = ERB.new( File.read('retrieved.erb'))
  res.body << template.result( binding)
}

# データ修正を定義
server.mount_proc("/edit") { |req, res|
  p req.query
  template = ERB.new(File.read('empty.erb'))

  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh['AutoCommit']=false
  begin
    dbh.transaction do
      # id重複チェック
      # idに変更が加えられるときに変更後idに一致するデータがあるなら変更を加えない
      if(req.query['id']!=req.query['prev_id'] &&
        dbh.select_one("select id from bookinfos where id='#{req.query['id'].gsub(/'/,"''").gsub(/\0/,"")}';") )
        # 変更後idと重複するデータを発見
        template = ERB.new(File.read('noentried.erb'))
      else
        # 更新
        # BugTrack
        # 更新時に主キーが重複するとConstraintExceptionが投げられるが,
        # その段階でデータベースとの接続を切断すると,BusyExceptionが投げられるため切断できない
        dbh.do("update bookinfos set id='#{req.query['id'].gsub(/'/,"''").gsub(/\0/,"")}', \
        title='#{req.query['title'].gsub(/'/,"''").gsub(/\0/,"")}',\
        author='#{req.query['author'].gsub(/'/,"''").gsub(/\0/,"")}', \
        yomi='#{req.query['yomi'].gsub(/'/,"''").gsub(/\0/,"")}', \
        publisher='#{req.query['publisher'].gsub(/'/,"''").gsub(/\0/,"")}',\
        page='#{req.query['page'].gsub(/'/,"''").gsub(/\0/,"")}', \
        price='#{req.query['price'].gsub(/'/,"''").gsub(/\0/,"")}', \
        purchase_price='#{req.query['purchase_price'].gsub(/'/,"''").gsub(/\0/,"")}',\
        isbn_10='#{req.query['isbn_10'].gsub(/'/,"''").gsub(/\0/,"")}', \
        isbn_13='#{req.query['isbn_13'].gsub(/'/,"''").gsub(/\0/,"")}', \
        size='#{req.query['size'].gsub(/'/,"''").gsub(/\0/,"")}', \
        publish_date='#{req.query['publish_date'].gsub(/'/,"''").gsub(/\0/,"")}', \
        purchase_date='#{req.query['purchase_date'].gsub(/'/,"''").gsub(/\0/,"")}',\
        purchase_reason='#{req.query['purchase_reason'].gsub(/'/,"''").gsub(/\0/,"")}', \
        notes='#{req.query['notes'].gsub(/'/,"''").gsub(/\0/,"")}'\
        where id='#{req.query['prev_id'].gsub(/'/,"''").gsub(/\0/,"")}';")
        template = ERB.new(File.read('edited.erb'))
      end
    end
  rescue => e
    p e
    puts "SQLite3:rollback"
    template = ERB.new(File.read('sqlerror.erb'))
  ensure
    res.body << template.result( binding )
  end
  dbh.disconnect if dbh!=nil
}

# データ削除を定義
server.mount_proc("/delete") { |req, res|
  p req.query
  template = ERB.new( File.read('empty.erb'))
  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh["AutoCommit"]=false
  begin
    dbh.transaction do
      dbh.do("delete from bookinfos where id='#{req.query['id'].gsub(/'/,"''").gsub(/\0/,"")}';")
      template = ERB.new( File.read('deleted.erb'))
    end
  rescue => e
    p e
  ensure
    res.body << template.result( binding)
  end
  dbh.disconnect if dbh!=nil
}

# シグナルをトラップ
trap(:INT) do
  server.shutdown
end
# サーバー起動
server.start
