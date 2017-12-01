#-*- coding: utf-8 -*-
require "sparql/client"
require 'open-uri'
require 'anemone'
require 'nokogiri'
require 'net/http'
require 'jason'

WORD = ARGV[0]
URL = 'http://ja.dbpedia.org/resource/' + WORD
client = SPARQL::Client.new("http://ja.dbpedia.org/sparql")

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
results.each do |solution|
    request_URL = URI.escape("https://api.apitore.com/api/8/word2vec-neologd-jawiki/similarity?access_token=4af25e9f-e0ac-46e8-b6da-f89590b8af29&word1=" + WORD + "&word2=" + solution[:thing2].to_s)
    page = URI.parse(request_URL).read
    charset = page.charset
    if charset == "iso-8859-1"
      charset = page.scan(/charset="?([^\s"]*)/i).first.join
    end
    doc = Nokogiri::HTML(page, request_URL,charset)
    jtod = JSON.parse(doc)
    d[URI.unescape(jtod['word2'].to_s)] = URI.unescape(jtod['similarity'].to_s)
end

p Hash[d.sort_by{|_,v|-v}]
