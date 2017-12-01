# -- coding : utf-8 --
require 'anemone'
require 'URI'
require 'nokogiri'
require 'open-uri'

PATTERN = %r[\.jpg$|\.jpeg$|\.png$|\.gif$/\.bmp$|\.svg$|\/%23|\/wiki\/]
WORD = ARGV[0]
URL = URI.escape('https://ja.wikipedia.org/wiki/' + WORD)
doc = Nokogiri::HTML(open(URL))
objects = doc.xpath('//a[not(.=preceding::a)][not(@class)][not(@dir)][not(contains(@href, "#"))]')
objects.each do |object|
    if object !~ PATTERN
        puts object.content()
    end
end  

=begin
Anemone.crawl(URL, depth_limit: 1, delay: 1) do |anemone|
    anemone.focus_crawl do |page|
        page.links.keep_if { |link|
            #wikiを含むURLのみ取得
            link.to_s.match(/\/wiki/)
        }
    end
    anemone.skip_links_like PATTERN

    anemone.on_every_page do |page|
        puts URI.unescape(page.url.request_uri[6..-1])
    end
end
=end
