#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'rubygems'
require 'dbi'
require 'date'

SEPARATOR = "+----------------------------------------------------------+"

load 'Util.rb'

# 蔵書データクラス
#
class BookInfo
	def initialize(title, author, page, publish_date)
		@title = title
		@author = author
		@page = page
		@publish_date = publish_date
	end

	attr_accessor :title, :author, :page, :publish_date

	def to_csv(key)
		"#{key},#{@title},#{@author},#{@page},#{@publish_date}\n"
	end
	# BookInfoクラスのインスタンスの文字列表現を返す
	def to_s
		"#{@title}, #{@author}, #{@page}, #{@publish_date}"
	end

	# 蔵書データを書式をつけて出力する操作を追加する
	# 項目の区切り文字を引数に指定することができる
	# 引数を省略した場合は改行を区切り文字にする
	def toFormattedString( sep = "\n")
		"書籍名:#{@title}#{sep}著者名:#{@author}#{sep}ページ数:#{@page}ページ#{sep}発刊日:#{publish_date}#{sep}"
	end
end


# 蔵書データ管理クラス
#
class BookInfoManager
	def initialize(sqlite_name)
		@db_name = sqlite_name
		@dbh = DBI.connect( "DBI:SQLite3:#{@db_name}" )
	end

	# 蔵書データをセットアップする
	def initBookInfos
		puts "\n0.データベースの初期化"
		print "初期化しますか？\n"
		if Util.yesno
			@dbh.do("drop table if exists bookinfos")
			@dbh.do("create table bookinfos(
				id 		varchar(50)		not null,
				title	varchar(100)	not null,
				author	varchar(100) 	not null,
				page	int  			not null,
				publish_date 	datetime not null,
				primary	key(id));
			")
			puts "\nデータベースを初期化しました。"
		end
	end

  # 蔵書データをデータベースに追加する
  #
  def addBookInfo(book_info, key)
  	if (key=="" || key==nil)
  		puts "キーが不正です"
  		return false
  	end

  	# if @book_infos.has_key?(key)
  	# 	puts "[警告]キーが重複する書籍データが存在します"
  	# 	puts "上書きしてもよろしいですか？"
  	# 	if Util.yesno
  	# 		puts "データを上書きします"
  	# 	else
  	# 		puts "追加はキャンセルされました"
  	# 		return false
  	# 	end
  	# end


  	@dbh.do("insert into bookinfos values (
  		\'#{key}\',
  		\'#{book_info.title}\',
  		\'#{book_info.author}\',
  		\'#{book_info.page}\',
  		\'#{book_info.publish_date}\');
  	")
  	puts "\n登録しました。"


  	# # @book_infos[key] = book_info
  	# puts "#{SEPARATOR}"
  	# puts "[key:#{key}]"
  	# print @book_infos[key].toFormattedString
  	# puts "#{SEPARATOR}"
  	# puts "データは正常に登録されました"
  	return true
  end

  # 蔵書データをユーザ対話方式（ウィザード）で登録する
  def addBookInfoWizard
    # 蔵書データ1件分のインスタンスを作成する
    book_info = BookInfo.new( "", "", 0, Date.new )
    # 登録するデータを項目ごと入力する
    begin
    	print "\n"
    	print "キー:"
    	key = gets.chomp
    	print "書籍名:"
    	book_info.title = gets.chomp
    	print "著者名:"
    	book_info.author = gets.chomp
    	print "ページ数:"
    	book_info.page = gets.chomp.to_i
    	print "発刊年:"
    	year = gets.chomp.to_i
    	print "発刊月:"
    	month = gets.chomp.to_i
    	print "発刊日:"
    	day = gets.chomp.to_i
    	book_info.publish_date = Date.new(year, month, day)
    rescue Interrupt
    	puts "割り込みで終了しました"
    rescue => e # StandardError
    	puts "入力が不正です"
    	return
    end
    # 作成したデータの1件分をハッシュに登録する
    addBookInfo(book_info, key)
end

def addBookInfoCSV
	begin
		while true
        # 蔵書データ1件分のインスタンスを作成する
        book_info = BookInfo.new( "", "", 0, Date.new )
        puts "カンマ区切りで入力してください Ctrl-cで入力モードを終了します"
        puts "ハッシュキー, 書籍名,著者名, ページ数, 発刊年, 発刊月, 発刊日"
        print "$ >"
        raw_csv = gets.chomp.strip

        # カンマが含まれるまで読み取る
        # 文字列として扱うなら先頭と末尾の空白を除去
        # 整数値して扱うなら整数値に変換
        begin
          # raw_csv.slice!(0..(raw_csv =~ /,/))
          # raw_csv中で最初にカンマが出てきたインデックスまで取り除き、
          # とり出された文字列に対して各処理を行う
          # strip : 文字列の前後のスペースやタブの除去
          # chop : 文字列の最後の文字の除去（カンマの除去を目的とする処理）
          key =  raw_csv.slice!(0..(raw_csv =~ /,/)).strip.chop
          book_info.title = raw_csv.slice!(0..(raw_csv =~ /,/)).strip.chop
          book_info.author = raw_csv.slice!(0..(raw_csv =~ /,/)).strip.chop
          book_info.page = raw_csv.slice!(0..(raw_csv =~ /,/)).to_i
          year = raw_csv.slice!(0..(raw_csv =~ /,/)).to_i
          month .slice!(0..(raw_csv =~ /,/)).to_i
          day = raw_csv.slice!(0..(raw_csv =~ /,|.$/)).to_i
          book_info.publish_date = Date.new(year, month, day)
        rescue => e # StandardError
        	puts "入力データが不正です"
        else
        	addBookInfo(book_info, key)
        end
    end

rescue Interrupt
	puts "\n書籍データ入力を終了します"
end
end

  #蔵書データの一覧を表示する
  def listAllBookInfos
  	item_name = {'id' => "キー", 'title' => "書籍名",'author' => "著者名", 'page' => "ページ数",
  		'publish_date' => "発刊日"}

  		puts "\n2.蔵書データの表示"
  		puts "蔵書データを表示します。"
  		puts "\n#{SEPARATOR}"

  		sth = @dbh.execute("select * from bookinfos")
  		counts = 0
  		sth.each do |row|
  			row.each_with_name do |val, name|
  				puts "#{item_name[name]} : #{val.to_s}"
  			end
  			puts "#{SEPARATOR}"
  			counts += 1
  		end
  		sth.finish
  		puts "\n#{counts.to_s}件表示しました。"
  	end

  # 蔵書データから検索する
  def search
  	begin
      # 検索するデータを項目ごと入力する
      print "\n"
      print "キー:"
      key = gets.chomp
      print "書籍名:"
      title = gets.chomp
      print "著者名:"
      author = gets.gsub(/(\s|　|\n)+/, '') # 半角/全角スペースと改行文字の除去
      print "ページ数:"
      page = gets.to_i
      print "発刊年:"
      tmp = gets.to_i
      year = tmp==0 ? nil : tmp
      print "発刊月:"
      tmp = gets.to_i
      month = tmp==0 ? nil : tmp
      print "発刊日:"
      tmp = gets.to_i
      day =  tmp==0 ? nil : tmp

      query_head = "select * from bookinfos where "
      query_foot = ";"
      query_body = ""
      query_body += (key!="")? "id=\'#{key}\', ": ""
      query_body += (title!="")? "title=\'#{title}\', " : ""
      query_body += (author!="")? "author=\'#{author}\', " : ""
      query_body += (page!=0)? "page=#{page}, " : ""
      query_body += "publish_date like \'"
      query_body += (year!=nil) ? "#{year}-" : "%-"
      query_body += (month!=nil) ? "#{month}-" : "%-"
      query_body += (day!=nil) ? "#{day}" : "%"
      query_body += "\'"
      query = query_head + query_body + query_foot
      puts query
      sth = @dbh.execute(query)

  rescue Interrupt
  	puts "検索を終了します"
  else
  	item_name = {'id' => "キー", 'title' => "書籍名",'author' => "著者名", 'page' => "ページ数", 'publish_date' => "発刊日"}
  	puts "#{SEPARATOR}"
  	counts = 0
  	sth.each do |row|
  		row.each_with_name do |val, name|
  			puts "#{item_name[name]} : #{val.to_s}"
  		end
  		puts "#{SEPARATOR}"
  		counts += 1
  	end
  	sth.finish
  	puts "\n#{counts.to_s}件表示しました。"
  end
end

def updateBookInfo
	begin
      # 登録するデータを項目ごと入力する
      print "\n"
      print "キー:"
      key = gets.chomp
      query = "select * from bookinfos where id=\'#{key}\';"
      row = @dbh.select_one(query)
      if row==nil
      	raise "一致する蔵書データが存在しません。"
      end
      row_item = Hash.new()

      puts SEPARATOR
      row.each_with_name do |val, name|
      	puts "#{item_name[name]} : #{val.to_s}"
      	row_item[name] = val
      end

      puts row_item["publish_date"]
      title = row_item["title"]
      author = row_item["author"]
      page = row_item["page"]
      publish_date = Date.strptime(row_item["publish_date"], "%Y-%m-%d")
      year = publish_date.year
      month = publish_date.month
      day = publish_date.day

      puts SEPARATOR

      print "書籍名: #{title} => "
      title = gets.chomp
      print "著者名: #{author} => "
      author = gets.gsub(/(\s|　|\n)+/, '') # 半角/全角スペースと改行文字の除去
      print "ページ数: #{page} => "
      page = gets.to_i
      print "発刊年: #{year} => "
      tmp = gets.to_i
      year = tmp==0 ? year : tmp
      print "発刊月: #{month} => "
      tmp = gets.to_i
      month = tmp==0 ? month : tmp
      print "発刊日: #{day} => "
      tmp = gets.to_i
      day =  tmp==0 ? day : tmp
      publish_date = Date.new(year, month, day)

      query_head = "update bookinfos set "
      query_foot = " where id=\'#{key}\';"
      query_body = ""
      query_body += (title!="")? "title=\'#{title}\', " : ""
      query_body += (author!="")? "author=\'#{author}\', " : ""
      query_body += (page!=0)? "page=#{page}, " : ""
      query_body += "publish_date=\'#{publish_date.to_s}\'"
      if query_body==""
      	raise "更新する値を設定してください。"
      end
      query = query_head + query_body + query_foot
      puts query
      @dbh.do(query)

  rescue Interrupt
  	puts "更新を終了します"
  rescue => e
  	puts e.to_s
  end
end

def deleteBookInfo
	print "\n削除するデータを指定してください"
	print "キー:"
	key = gets.chomp
	if key==""
		puts "キーを入力してください"
		return
	end
	query = "delete from bookinfos where id=\'#{key}\';"
	@dbh.do(query)
	puts "削除されました"
end

 # 処理の選択と選択後の処理を繰り返す
 def run
 	while true
      # 機能選択画面を表示する
      print "\n"+
      "0.蔵書データの初期化\n"+
      "1.蔵書データの登録(対話方式)\n"+
      "2.蔵書データの登録(カンマ区切り方式)\n"+
      "3.蔵書データの表示\n"+
      "4.蔵書データの検索\n"+
      "5.蔵書データの更新\n"+
      "6.蔵書データの削除\n"+
      "9.終了\n"+
      "番号を選んでください(0,1,2,3,4,9) :"

      # 文字の入力を待つ
      num = gets.chomp
      case
      when '0' == num
      	#データベースの初期化
      	initBookInfos
      when '1' == num
        #蔵書データの登録
        addBookInfoWizard
    when '2' == num
        #蔵書データの登録
        addBookInfoCSV
    when '3' == num
        #蔵書データの表示
        listAllBookInfos
    when '4' == num
        #蔵書データ内検索
        search
    when '5' == num
    	#蔵書データの更新
    	updateBookInfo
    when '6' == num
    	#蔵書データの削除
    	deleteBookInfo
    when '9' == num
        # アプリケーションの終了
        break
    when '' == num
    	puts "番号を入力してください"
    else
        # 処理選択待ち画面に戻る
        puts "該当する命令が存在しません"
    end
end
end
end

book_info_manager = BookInfoManager.new("bookinfo_sqlite.db")
book_info_manager.run