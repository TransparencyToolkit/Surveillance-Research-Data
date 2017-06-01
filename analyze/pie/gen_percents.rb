require 'json'
require 'pry'

class GenPercents
  def initialize(file, filter_field, filter_val, percent_field)
    @json = JSON.parse(File.read(file))
    @filter_field = filter_field
    @filter_val = filter_val
    @percent_field = percent_field
    @output = Array.new
  end

  def gen_pie
    filtered = filter_results
    sum_result_vals(filtered)
  end

  # Sum up the results and also group by other
  def sum_result_vals(filtered)
    options = filtered.map{|item| item[@percent_field]}.flatten.map.uniq
    options_hash = options.inject({}){|hsh, item| hsh[item] = filtered.select{|fil| fil[@percent_field].include?(item)}.length; hsh}

    # Add up total and calculate %
    sum = options_hash.inject(0){|sum, item| sum+=item[1];sum}
    percents = options_hash.inject({}){|per, item| per[item[0]] = (item[1].to_f/sum.to_f); per}

    # Handle other
    top_vals = percents.sort_by { |k,v| v}.reverse[0..20]
    other = 1- top_vals.inject(0){|sum, val| sum+=val[1]; sum}
    pushed = top_vals.push(["Other", other])
    @output = pushed.map{|val| [val[0], val[1]*100]}
  end

  # Filter the results to have only those with a field of a given value
  def filter_results
    @json.select{|item| item[@filter_field].include?(@filter_val)}
  end

  def gen_json
    JSON.pretty_generate(@output)
  end
end

file1 = "../../processed_data/parsed_data.json"
g = GenPercents.new(file1, "catalyst_tools", "proxy", "catalyst_countries")
g.gen_pie
puts g.gen_json
