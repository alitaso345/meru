require 'tesseract-ocr'
require 'open-uri'

@path = 'http://pbs.twimg.com/media/B_-8jUpUYAAiX-2.jpg'

fileName = File.basename(@path)

open(fileName, 'wb') do |output|     #※１
  open(@path) do |data|
    output.write(data.read)          #※２
  end
end

engine = Tesseract::Engine.new{ |engine|
    engine.language = :jpn
}

puts engine.text_for(fileName)
