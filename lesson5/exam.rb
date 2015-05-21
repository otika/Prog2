#! ruby -Ku
# -*- coding:utf-8 -*-

def pad_to_print_size(string, size)
  print_size = string.each_char.map{|c| c.bytesize == 1 ? 1 : 2}.reduce(0, &:+)
  padding_size = size - print_size
  padding_size = 0 if size < 0
  ' ' * padding_size + string
end

# テスト成績クラス
# total 成績合計値
class ExamRecord < Hash
  def total
    ret = 0
    self.each{|key,val|
      ret += val
    }
    ret
  end
end

# 学生クラス
class Student
  def initialize(name, record)
    raise 'ExamRecord only' unless record.is_a?(ExamRecord)
    @name = name
    @record = record
  end
  attr_accessor :name, :record
  def to_s
    "#{@name} #{@record.to_s}"
  end
end

# Entry Point
csvfile = ARGV[0].to_s
if !File.exist? csvfile
  puts "File Not Found"
  exit(1)
end

students = Array.new
item_names = Array.new

open(csvfile, "r"){|file|
  item_names = file.gets.chomp.split(",")
  studentCnt = 0
  file.each{|col|
    raw_array = col.chomp.split(",")
    name = raw_array[0]
    record = ExamRecord.new
    for i in 1...item_names.length do
      record[item_names[i]] = raw_array[i].to_i
    end
    students[studentCnt] = Student.new(name, record)
    studentCnt += 1
  }
}

# 合計点数でソート
students.sort!{|a,b|
  b.record.total <=> a.record.total
}

# 項目名表示
item_names.each{|item_name|
  print "#{pad_to_print_size(item_name, 8)}|"
}
print "#{pad_to_print_size("合計", 8)}|"
puts
puts (('-'*8)+'+')*(item_names.length+1)
# 学生の名前、特典、合計値を表示
students.each{|student|
  print "#{pad_to_print_size(student.name, 8)}|"
  item_names.drop(1).each{|item|
    print "#{pad_to_print_size(student.record[item].to_s, 8)}|"
  }
  print "#{pad_to_print_size(student.record.total.to_s, 8)}|"
  puts
}
puts (('-'*8)+'+')*(item_names.length+1)

# 平均
averages = Hash.new
total_average = 0

students.each{|student|
  item_names.drop(1).each{|item|
    averages[item]=0 if averages[item]==nil
    averages[item] += student.record[item]
  }
}
item_names.drop(1).each{|item| averages[item] /= students.length.to_f }
students.each{|student| total_average += student.record.total}
total_average /= students.length.to_f

print "#{pad_to_print_size("平均",8)}|"
item_names.drop(1).each{|item|
  print "#{pad_to_print_size(sprintf("%.1f",averages[item]), 8)}|"
}
puts "#{pad_to_print_size(sprintf("%.1f",total_average),8)}|"
puts (('-'*8)+'+')*(item_names.length+1)
# 標準偏差
sds = Hash.new
total_sd = 0
students.each{|student|
  item_names.drop(1).each{|item|
    sds[item] = 0 if sds[item] == nil
    sds[item] += (student.record[item] - averages[item])**2
  }
  total_sd += (student.record.total - total_average)**2
}
item_names.drop(1).each{|item| sds[item] /= students.length.to_f }
total_sd /= students.length

print "#{pad_to_print_size("標準偏差",8)}|"
item_names.drop(1).each{|item|
  print "#{pad_to_print_size(sprintf("%.1f",sds[item]), 8)}|"
}
puts "#{pad_to_print_size(sprintf("%.1f",total_sd),8)}|"
puts (('-'*8)+'+')*(item_names.length+1)
