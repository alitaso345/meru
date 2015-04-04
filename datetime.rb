#日付の文字列(XXXX年YY月ZZ日)からdateオブジェクトを得るスクリプト
require 'date'
def jpndate(str)
  today = Date.today
  year = 9999
  month = 12
  day = 31
  str.scan(/(午前|午後)?(\d+)(年|月|日)/) do
    case $3
    when "年"
      year = $2.to_i
    when "月"
      month = $2.to_i
    when "日"
      day = $2.to_i
    end
  end
  return Date.new(year, month, day).to_s
end

