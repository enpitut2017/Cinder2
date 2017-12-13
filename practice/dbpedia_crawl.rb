#-*- coding: utf-8 -*-
require 'sparql/client'
require 'open-uri'
require 'anemone'
require 'nokogiri'
require 'json'
require 'net/https'
require 'uri'

WORD = ARGV[0]
URL = 'http://ja.dbpedia.org/resource/' + WORD
client = SPARQL::Client.new("http://ja.dbpedia.org/sparql")
a_token = ENV['a_token'] #アクセストークン

redirect = client.query("
SELECT *
WHERE {
  <" + URL + "> dbpedia-owl:wikiPageRedirects ?thing1 .
  ?thing1 rdfs:label ?thing2 .
}
")
if redirect.size == 0 then
   results = client.query("
   SELECT *
   WHERE {
     <" + URL + "> dbpedia-owl:wikiPageWikiLink ?thing1 .
     ?thing1 rdfs:label ?thing2 .
   }
   ") 
else
    results = client.query("
    SELECT *
    WHERE {
      <" + "#{redirect[0][:thing1]}" + "> dbpedia-owl:wikiPageWikiLink ?thing1 .
      ?thing1 rdfs:label ?thing2 .
    }
    ") 
end

d = {}
count = 0
results.each do |solution|
  if count < 10 then 
    request_URL = URI.escape("https://api.apitore.com/api/8/word2vec-neologd-jawiki/similarity?access_token=" + a_token.to_s + "&word1=" + WORD.to_s + "&word2=" + solution[:thing2].to_s)
    charset = nil
    html = open(request_URL, :redirect => false) do |f|
      charset = f.charset #文字種別を取得します。
      f.read #htmlを読み込み変数htmlに渡します。
    end
    doc = Nokogiri::HTML.parse(html, nil, charset)
    jtod = JSON.parse(doc)
    d[URI.unescape(jtod['word2'].to_s)] = URI.unescape(jtod['similarity'].to_s)
  end
end

json_str = JSON.pretty_generate(Hash[d.sort_by{|_,v|-v}])
puts json_str

