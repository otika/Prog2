#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# Studentクラスを作る
class Student
  # Studentクラスのインスタンスを初期化する
  def initialize( name, age)
  	@name = name
  	@age = age
  end

  # Studentクラスの文字列表現を返す
  def to_s
  	"#@name, #@age"
  end
end

# Studentクラスのインスタンスを作成し、shinという名前をつける
shin = Student.new('久保秋　真', 45)
hiroshi = Student.new('久保秋　博', 41)

# shinの名前と年齢を表示する
puts shin.to_s
puts hiroshi.to_s
