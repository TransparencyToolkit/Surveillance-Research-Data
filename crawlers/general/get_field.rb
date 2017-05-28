require 'json'

file = "raw_citizenlab_report_data.json"
field = "tags"

json = JSON.parse(File.read(file))
File.write("#{field}.json", JSON.pretty_generate(json.map{|item| item[field]}.flatten.uniq))
