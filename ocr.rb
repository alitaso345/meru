require 'tesseract-ocr'

engine = Tesseract::Engine.new{ |engine|
    engine.language = :jpn
}

puts engine.text_for('shift_kozue.jpg')
