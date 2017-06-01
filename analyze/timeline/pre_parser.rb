require 'json'
require 'pry'

# Preparses file into hashes by term and year
class PreParser
  def initialize(file, field, year_field)
    @json = JSON.parse(File.read(file))
    @field = field
    @year_field = year_field
  end

  def parse
    all_terms = @json.map{|item| item[@field]}.flatten.uniq
    @term_hash = all_terms.inject({}){|hsh, item| hsh[item] = {}; hsh}
    @json.each do |item|
      if item["date"]
        year = Date.parse(item["date"]).year 

        # Add year for each term
        item_keys = item[@field].is_a?(Array) ? item[@field] : [item[@field]]
        item_keys.each do |key|
          # Increment
          if @term_hash[key][year]
            @term_hash[key][year] += 1
          else # Initialize (does not exist)
            @term_hash[key][year] = 1
          end
        end
      end
    end
  end

  def gen_output
    JSON.pretty_generate(@term_hash)
  end
end

field = "catalyst_companies"
year_field = "date"
p = PreParser.new("../../processed_data/parsed_data.json", field, year_field)
p.parse
puts p.gen_output
