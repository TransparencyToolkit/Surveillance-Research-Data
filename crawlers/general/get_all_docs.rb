require 'curb'
require 'json'
require 'pry'

# wget http://localhost:3000/get_all_docs?index_name=surveillance_research_archive

processed = JSON.parse(File.read("processed.json"))["hits"]["hits"]
File.write("parsed_data.json", JSON.pretty_generate(processed.map{|item| item["_source"]}))
