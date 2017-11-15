# -- coding : utf-8 --
require 'anemone'
require 'URI'

WORD = ARGV[0]
URL = URI.escape('https://ja.wikipedia.org/wiki/' + WORD)
PATTERN = %r[\.jpg$|\.jpeg$|\.png$|\.gif$/\.bmp$|\.svg$|^/wiki/#.*$]
Anemone.crawl(URL, depth_limit: 1) do |anemone|
    anemone.focus_crawl do |page|
        page.links.keep_if { |link|
            #wikiを含むURLのみ取得
            link.to_s.match(/\/wiki/)
        }
    end
    anemone.skip_links_like PATTERN
    anemone.on_every_page do |page|
        puts URI.unescape(page.url.request_uri)
    end
end
