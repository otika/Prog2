load "Util.rb"
load "BookInfo.rb"

SEPARATOR = "+----------------------------------------------------------+"

# このクラスはUtilクラスに依存しています
class BookInfoManager
  def initialize
    @book_infos = {}  # 蔵書ストア
    self.setUp
  end

  # 蔵書データをセットアップする
  def setUp
    # 複数冊の蔵書データを登録する
    @book_infos = Hash.new

    @book_infos['Yamada2005'] = BookInfo.new(
    "実践アジャイル ソフトウェア開発法とプロジェクト管理",
    "山田 正樹",
    248,
    Date.new(2005,1,25)
    )

    @book_infos ['Ooba2006'] = BookInfo.new(
    "入門LEGO　MINDSTORMS NXT　レゴブロックで作る動くロボット",
    "大庭　慎一郎",
    164,
    Date.new(2006,12,23)
    )
  end

  # 蔵書データをストアに追加する
  #
  def addBookInfo(book_info, key)
    if (key=="" || key==nil)
      puts "キーが不正です"
      return false
    end
    if @book_infos.has_key?(key)
      puts "[警告]キーが重複する書籍データが存在します"
      puts "上書きしてもよろしいですか？"
      if Util.yesno
        puts "データを上書きします"
      else
        puts "追加はキャンセルされました"
        return false
      end
    end
    @book_infos[key] = book_info
    puts "#{SEPARATOR}"
    puts "[key:#{key}]"
    print @book_infos[key].toFormattedString
    puts "#{SEPARATOR}"
    puts "データは正常に登録されました"
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
          month = raw_csv.slice!(0..(raw_csv =~ /,/)).to_i
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
    puts "\n#{SEPARATOR}"
    @book_infos.each { |key, info|
      print info.toFormattedString
      puts "#{SEPARATOR}"
    }
  end

  # 蔵書データから検索する
  def search
    begin
      # 登録するデータを項目ごと入力する
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
      puts "#{SEPARATOR}"
    rescue Interrupt
      puts "検索を終了します"
    else
      @book_infos.each{ |book_info_key,book_info|
        if (
          ( key == "" || book_info_key.to_s.index(key) ) &&
          ( title == "" || book_info.title.index(title) ) &&
          ( author == "" || book_info.author.gsub(/(\s|　)+/, '').index(author) ) &&
          ( page == 0  || book_info.page == page ) &&
          ( year == nil || book_info.publish_date.year == year ) &&
          ( month == nil || book_info.publish_date.month == month ) &&
          ( day == nil || book_info.publish_date.day == day)
          )
          # Matching Pass
          print book_info.toFormattedString
          puts "#{SEPARATOR}"
        end
      }
    end
  end

  # 処理の選択と選択後の処理を繰り返す
  def run
    while true
      # 機能選択画面を表示する
      print "\n"+
      "1.蔵書データの登録(対話方式)\n"+
      "2.蔵書データの登録(カンマ区切り方式)\n"+
      "3.蔵書データの表示\n"+
      "4.蔵書データの検索\n"+
      "9.終了\n"+
      "[Ctrl-cで強制終了します]\n"+
      "番号を選んでください(1,2,3,4,9) :"

      # 文字の入力を待つ
      num = gets.chomp
      case
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
      when '9' == num
        # アプリケーションの終了
        raise Interrupt.new("Ctrl-c")
      when '' == num
        puts "番号を入力してください"
      else
        # 処理選択待ち画面に戻る
        puts "該当する命令が存在しません"
      end
    end
  end
end
