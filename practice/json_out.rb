require 'json'

dict = {}
dict["シードル"] = "0.61"
dict["リンゴ"] = "0.7666"
dict["ノカイドウ"] = "0.422"
dict["塩水"] = "0.2775"
dict["ヘプタコサン"] = "0.261"
json_str = JSON.pretty_generate(Hash[dict.sort_by{|_,v|-v}])
puts json_str