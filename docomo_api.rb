# 文字認識docomoAPIで画像の中の文章を取得するスクリプト
require 'rest_client'
require 'json'
require_relative "datetime"

API_KEY = ENV['DOCOMO_API_KEY']

class DocomoAPI
  def initialize
    @id = 0
    @uri = URI('https://api.apigw.smt.docomo.ne.jp/characterRecognition/v1/document')
  end

  ###   画像認識要求   ###
  def req_ocr(picture)
    @uri.query = 'APIKEY=' + API_KEY

    response = RestClient.post(
      @uri.to_s,
      {:image => File.open(picture),
       :lang => 'jpn'
    },
    :content_type => 'multipart/form-data'
    )

    # 得られた結果からidのみ出力
    json = JSON.parser.new(response)
    hash = json.parse()
    @id = hash['job']['@id']
  end

  ###   画像認識結果取得   ###
  def get_ocr
    @uri.path += "/" +  @id

    loop do
      result = RestClient.get(@uri.to_s)
      json2 = JSON.parser.new(result)
      $hash = json2.parse()
      # 処理に成功した場合のみ処理を続行
      if $hash['job']['@status']=="success"
        break
      elsif $hash['job']['@status']!="process"
        p "失敗もしくは削除済みです"
        exit
      end
      sleep(0.5)#連続してRestClientすると怒られるのでお休み
    end

    # 得られたjsonのうち@textのみ出力
    text =  $hash['lines']['line']   
    text.each do |text|
      p jpndate((text['@text']).gsub(" ", ""))rescue nil
    end
  end
end
