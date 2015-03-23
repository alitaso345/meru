require 'nokogiri'
require 'open-uri'

class PremiumMaid
  def initialize
    url = "http://www.cafe-athome.com/" 
    charset = nil
    
    html = open(url) do |f|
      charset = f.charset
      f.read
    end

    @doc = Nokogiri::HTML.parse(html, nil, charset)
  end

  def get_json
    dic = Array.new()

    @doc.xpath("//div[@class='top-service-info-box']").each do |node|
      info = Hash.new
      info[:maid_name] = node.xpath(".//div[@class='maid-name']").text
      info[:service_time] = parse_text(node.xpath(".//div[@class='service-time']").text)
      dic.push(info)
    end

    dic
  end

  private
  def parse_text(text)
    text
  end
end
