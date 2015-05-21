#! /usr/bin/ruby -Ku
# -*- coding: utf-8 -*-

require 'rubygems'
require 'dbi'

dbh = DBI.connect('DBI:SQLite3:students01.db')

dbh.select_all('select * from students') do | row |
STDOUT.print "row=#{row}\n"
STDOUT.print " name = #{row[0]}\n"
STDOUT.print " age = #{row[1]}\n"
STDOUT.print "\n"
end

dbh.disconnect
