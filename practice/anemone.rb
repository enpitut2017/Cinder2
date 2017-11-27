# -*- coding : utf-8 -*-
require 'anemone'

URL = ARGV[0]
Anemone.crawl(URL, depth_limit: 2) do |anemone|
    anemone.on_every_page do |page|
        #URLを取得
        puts page.url
    end
end
