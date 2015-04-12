# 文字認識docomoAPIで画像の中の文章を取得するスクリプト
require 'rest_client'
require 'json'
require 'date'

API_KEY = ENV['DOCOMO_API_KEY']

class DocomoAPI
  def initialize(file)
    @file = file
    @id = 0
    @document_uri = URI('https://api.apigw.smt.docomo.ne.jp/characterRecognition/v1/document')
    @face_detection_uri = URI('https://api.apigw.smt.docomo.ne.jp/puxImageRecognition/v1/faceDetection')
  end

  # Return docomo face detection API result
  # @return Hash[data: Hash, status: String]
  def req_face_detection
    @face_detection_uri.query = 'APIKEY=' + API_KEY
    options = {
      :inputFile => @file,
      :optionFlgMinFaceWidth => 1,
      :blinkJudge => 0,
      :angleJudgej => 0,
      :smileJudge => 0,
      :enjoyJudge => 0,
      :response => "json"
    }

    response = RestClient.post(@face_detection_uri.to_s, options, :content_type => 'multipart/form-data')
    data = JSON.parser.new(response).parse()['results']['faceRecognition']
    {data: data, status: check_face_status(data)}
  end

  ###   画像認識要求   ###
  def req_ocr
    @document_uri.query = 'APIKEY=' + API_KEY

    options = {
      :image => File.open("./image/servise-time.jpg"), 
      :lang => 'jpn'
    }
    response = RestClient.post(@document_uri.to_s, options, :content_type => 'multipart/form-data')

    # 得られた結果からidのみ出力
    hash = JSON.parser.new(response).parse()
    @id = hash['job']['@id']
  end

  ###   画像認識結果取得   ###
  def get_ocr
    @document_uri.path += "/" +  @id

    loop do
      @result = RestClient.get(@document_uri.to_s)
      status = check_ocr_status(JSON.parser.new(@result).parse())
      sleep 0.5
      break if status != "process"
    end

    status = check_ocr_status(JSON.parser.new(@result).parse())
    data = JSON.parser.new(@result).parse()
    {data: data, status: status}
  end

  private
  def check_ocr_status(data)
    status = data['job']['@status']
    if status == "success"
      "success"
    elsif status == "process"
      "process"
    else
      status
    end
  end

  def check_face_status(data)
    error = data['errorInfo']
    if error == ""
      "success"
    elsif error == "NoFace"
      "no_face"
    else
      "error"
    end
  end

  # 文章をgrepで整形
  def pattern(str)
    str.gsub!(/[旧碑〇丨|I）}]/,
              "旧"=>"1日",
              "碑"=>"4年",
              "〇"=>"0",
              /[丨|I]/=>"1",
              /[）}>]/=>")")
    str.gsub(" ","")
  end

  #日付の文字列(XXXX年YY月ZZ日)からdateオブジェクトを得る
  def jpndate(str)
    @year=@month=@day=0
    str.scan(/(\d+)(年|月|日)/) do
      case $2 
      when "年"
        @year = $1.to_i
      when "月"
        @month = $1.to_i
      when "日"
        @day = $1.to_i
      end
    end
    # 得られた日付が存在する場合のみdateオブジェクトを返す
    if Date.valid_date?(@year, @month, @day)
      return Date.new(@year, @month, @day).to_s
    else
      return str
    end
  end
end

