#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-
require 'webrick'
require 'erb'
require 'rubygems'
require 'dbi'

jpnametable={
  'id' => "ID",
  'title' => "タイトル",
  'author' => "著者名",
  'yomi' => "よみがな",
  'publisher' => "出版社",
  'page' => "ページ数",
  'price' => "本体価格",
  'purchase_price' => "購入価格",
  'isbn_10' => "ISBN-10",
  'isbn_13' => "ISBN-13",
  'size' => "寸法",
  'publish_date' => "出版日",
  'purchase_date' => "購入日",
  'purchase_reason' => "購入理由",
  'notes' => "備考"
}

class String
  alias_method(:orig_concat, :concat)
  def concat(value)
    if RUBY_VERSION > "1.9"
      orig_concat value.force_encoding('UTF-8')
    else
      orig_concat value
    end
  end
  # HTML Escape
  def escapeHtml
    # &, <, >, ', " HTML制御文字を無効化
    self.gsub(/&/,'&amp;').gsub(/</,'&lt;').gsub(/>/,'&gt;').gsub(/"/,'&quot;').gsub(/'/,'&#39;')
  end
  # SQLite3 Escape
  def escapeSqlite3
    # SQLite3 インジェクション対策 シングルクオートとヌルを無効化
    self.gsub(/'/,"''").gsub(/\0/,"")
  end
  # SQLite3
  def escapeSqlite3Like(escape)
    # SQLite3 like句の制御文字のエスケープとエスケープ文字自身をエスケープ
    if escape==nil || escape.length!=1
      raise "Escape expression must be a single character"
    end
    self.escapeSqlite3.gsub(/([%_#{escape}])/,"#{escape}\\1")
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
server.mount_proc("/mainlist"){ |req, res|
  p req.query
  # ページ指定なしor0なら1ページ目表示
  page = req.query['page'].to_i
  page=1 if page==0
  displayitem = req.query['displayitem'].to_i
  displayitem=5 if displayitem==0
  template = ERB.new(File.read('list.erb'))
  res.body << template.result(binding)
}

# listから削除と修正を受け取る
server.mount_proc("/list") { |req, res|
  p req.query
  puts req.query['operation']
  template = ERB.new(File.read('empty.erb'))
  templateMsg1 = ""
  templateMsg2 = ""
  if /(.*)\.(delete|edit)$/ =~ req.query['operation']
    target_id = $1
    operation = $2
    if operation == 'delete'
      dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
      if nil != dbh.select_one("select id from bookinfos where id='#{target_id.escapeSqlite3}';")
        template = ERB.new( File.read('delete.erb'))
      else
        templateMsg1 = "蔵書データの削除"
        templateMsg2 = "指定したデータは存在しません"
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
  templateMsg1 = "蔵書データの登録"
  templateMsg2 = ""
  template = ERB.new(File.read('empty.erb'))

  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh['AutoCommit']=false
  begin
    # 不整合発生要因とならない
    # ID重複チェック
    rows = dbh.select_one("select * from bookinfos where id='#{req.query['id'].escapeSqlite3}';")

    # IDが指定されていることを確認
    if req.query['id'] == ''
      templateMsg2 = "IDを入力してください"
      puts "id empty"
    elsif req.query['id'] =~ /^[A-Za-z0-9]+$/
    # 英数字のみで構成されるID
      dbh.transaction do
        if rows then
          template = ERB.new( File.read('noentried.erb'))
          puts "id duplication error"
        else
          # Rubyのバージョンによりハッシュ順番が保証されないため決め打ち
          dbh.do("insert into bookinfos \
          values('#{req.query['id'].escapeSqlite3}', \
          '#{req.query['title'].escapeSqlite3}', \
          '#{req.query['author'].escapeSqlite3}',\
          '#{req.query['yomi'].escapeSqlite3}', \
          '#{req.query['publisher'].escapeSqlite3}', \
          '#{req.query['page'].escapeSqlite3}',\
          '#{req.query['price'].escapeSqlite3}', \
          '#{req.query['purchase_price'].escapeSqlite3}',\
          '#{req.query['isbn_10'].escapeSqlite3}',\
          '#{req.query['isbn_13'].escapeSqlite3}', \
          '#{req.query['size'].escapeSqlite3}',\
          '#{req.query['publish_date'].escapeSqlite3}', \
          '#{req.query['purchase_date'].escapeSqlite3}',\
          '#{req.query['purchase_reason'].escapeSqlite3}', \
          '#{req.query['notes'].escapeSqlite3}');")
          template = ERB.new( File.read('entried.erb'))
          puts "entried"
        end
      end
    else
      templateMsg2 = "IDには半角英数字以外使用しないでください"
      puts "invalidate id error"
    end
  rescue => e
    p e
    puts "SQLite3:rollback"
    templateMsg2 = "データベースエラーで処理が取り消されました"
  ensure
    res.body << template.result( binding )
  end
  dbh.disconnect if dbh!=nil
}

# データ検索を定義
server.mount_proc("/retrieve"){ |req,res|
  p req.query
  items = ['id', 'title', 'author', 'yomi', 'publisher', 'page', 'price',
    'purchase_price', 'isbn_10', 'isbn_13', 'size', 'publish_date',
    'purchase_date', 'purchase_reason', 'notes']
  # 検索対象に含まれない要素を消す
  items.delete_if{|name| req.query[name] == ""}

  # 検索対象が無い場合,where句を使わない
  if items.empty?
    where_date=""
  else
    items.map! {|name|
      "#{name} like \
      '%#{req.query[name].escapeSqlite3Like("$")}%'"
      }
    where_date = "where " + items.join(' or ') + " escape '$'"
  end
  template = ERB.new( File.read('retrieved.erb'))
  res.body << template.result( binding)
}

# フリーキーワード検索を定義
server.mount_proc("/freekeyword"){ |req,res|
  p req.query
  # idからnoteまでスペースを区切りとして文字列連結
  # フリーキーワードであいまい検索
  items = ['id', 'title', 'author', 'yomi', 'publisher', 'page', 'price',
    'purchase_price', 'isbn_10', 'isbn_13', 'size', 'publish_date',
    'purchase_date', 'purchase_reason', 'notes']

  where_date = "where upper( " + items.join("||' '||") + " ) like \
  '%#{req.query["keyword"].escapeSqlite3.gsub(/([%_$])/,'$\1' ).upcase}%' \
  escape '$'"
  template = ERB.new( File.read('retrieved.erb'))
  res.body << template.result( binding)
}

# データ修正を定義
server.mount_proc("/edit") { |req, res|
  p req.query
  template = ERB.new(File.read('empty.erb'))
  templateMsg1 = "蔵書データの修正"
  templateMsg2 = ""

  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh['AutoCommit']=false
  begin
    dbh.transaction do
      # id重複チェック
      # idに変更が加えられるときに変更後idに一致するデータがあるなら変更を加えない
      if(req.query['id']!=req.query['prev_id'] &&
        dbh.select_one("select id from bookinfos where id='#{req.query['id'].escapeSqlite3}';") )
        # 修正後IDとIDが重複するデータを発見
        template = ERB.new(File.read('noentried.erb'))
        puts "id duplication error"
        # 半角英数のみで構成されるID
      elsif !(req.query['id'] =~ /^[A-Za-z0-9]+$/)
        templateMsg2 = "IDには半角英数字以外使用しないでください"
        puts "invalidate id error"
      else
        # 更新
        # BugTrack
        # 更新時に主キーが重複するとConstraintExceptionが投げられるが,
        # その段階でデータベースとの接続を切断すると,BusyExceptionが投げられるため切断できない
        items = ['id', 'title', 'author', 'yomi', 'publisher', 'page', 'price', 'purchase_price', 'isbn_10', 'isbn_13', 'size', 'publish_date','purchase_date', 'purchase_reason', 'notes']
        items.map!{ |name|
          "#{name}='#{req.query[name].escapeSqlite3}'"
        }
        sqliteQuery = "update bookinfos set " + items.join(",") + "where id='#{req.query['prev_id'].escapeSqlite3}';"
        dbh.do sqliteQuery
        template = ERB.new(File.read('edited.erb'))
      end
    end
  rescue => e
    p e
    puts "SQLite3:rollback"
    puts e.backtrace.join("\n")
    templateMsg2 = "データベースエラーで処理が取り消されました"
  ensure
    res.body << template.result( binding )
  end
  dbh.disconnect if dbh!=nil
}

# データ削除を定義
server.mount_proc("/delete") { |req, res|
  p req.query
  templateMsg1 = "蔵書データの削除"
  templateMsg2 = ""
  template = ERB.new( File.read('empty.erb'))
  dbh = DBI.connect( 'DBI:SQLite3:bookinfo_sqlite.db')
  dbh["AutoCommit"]=false
  begin
    dbh.transaction do
      if 0 < dbh.do("delete from bookinfos where id='#{req.query['id'].escapeSqlite3}';")
        template = ERB.new( File.read('deleted.erb'))
      else
        templateMsg1 = "蔵書データの削除"
        templateMsg2 = "指定したデータは既に存在しません"
      end
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
