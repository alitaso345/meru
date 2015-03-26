#メイドさんの公式Twitterアカウントを取得するためのスクリプト
require 'anemone'
require 'nokogiri'
require 'logger'

class Crawler
  def initialize
    @maides_list = []
    @console = Logger.new(STDOUT)
  end

  def get_maides_info
    begin
      @console.info("Start crawl @homecafe")
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

          info = Hash.new
          info[:maid_number] = page.url.to_s.match(/\d{2,}/).to_s
          info[:name] = doc.xpath("//div[@id='maid-name']").text
          info[:twitter_account] = doc.xpath("//*[@id='maid-properties']/dl[3]/dd/a").to_s.delete('https://twitter.com/') || nil
          info[:floor] = doc.xpath("//*[@id='maid-properties']/dl[1]/dd/a[1]").text
          @maides_list << info
        end
      end 
      @console.info("Finish crawl")
      @maides_list
    rescue => e
      p e
    end
  end

  private
  def print_maid_info
    @maides_list.each do |maid|
      puts maid
    end
  end
end
