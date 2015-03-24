#メイドさんの公式Twitterアカウントを取得するためのスクリプト
require 'anemone'
require 'nokogiri'

#クロールの起点となるURLを指定
urls = [
  'http://www.cafe-athome.com/maids/free/',
  'http://www.cafe-athome.com/maids/honten7f/',
  'http://www.cafe-athome.com/maids/honte16f/',
  'http://www.cafe-athome.com/maids/honten4f/',
  'http://www.cafe-athome.com/maids/donki/',
  'http://www.cafe-athome.com/maids/new/'
]

Anemone.crawl(urls, :depth_limit  => 1, :skip_query_strings => true) do |anemone|
  #巡回先の絞り込み
  anemone.focus_crawl do |page|
    page.links.keep_if{ |link|
      link.to_s.match(/http:\/\/www.cafe-athome.com\/maids/)
    }
  end

  #取得したページに対する処理
  anemone.on_pages_like(/maids\/\d{1,}/) do |page|
    doc = Nokogiri::HTML.parse(page.body)
    
    name = doc.xpath("//div[@id='maid-name']").text
    twitter_account = doc.xpath("//div[@id='maid-properties']/dl/dd")[2].text
    if twitter_account.match(/^@/)
      puts "#{name} #{twitter_account} id:#{page.url.to_s.match(/\d{2,}/)}"
    else
      puts "#{name} no twitter account id:#{page.url.to_s.match(/\d{2,}/)}"
    end
  end
end