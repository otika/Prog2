#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

# 新しいハッシュを作る
friends = {
  :shin => "Shin Kuboaki",
  :shinchirou => "Shinichirou Ooba",
  :shinfo => "Shingo Katori"
}

# ハッシュに要素を追加する
friends[ :shinsaku ] = "Shinsaku Takasugi"

puts friends.include?( :shinsaku)
puts friends[:shinsaku]

# 追加した要素を削除する
friends.delete( :shinsaku )

# ハッシュの要素を検索する（見つからないはず）
if friends.include?( :shinsaku ) then
  puts friends[:shinsaku ]
else
  puts "Not Found"
end
