require 'json'
require 'pry'

class FormatResults
  def initialize(input, keys_to_format, start_year, filter_keys, merge_keys)
    @input = JSON.parse(File.read(input))
    @file_path = input
    @keys_to_format = keys_to_format
    @start_year = start_year
    @output = Hash.new
    @earliest_year = 2018
    @latest_year = 0
    @formatted_out = Array.new
    @filter_keys = filter_keys
    @merge_keys = merge_keys
  end

  # Put the years in numerical order in hash
  def order_years(item)
    return item.sort_by{|k, v| k.to_i}
  end

  # Remove the urls from the item, leaving only the counts
  def remove_urls(item)
    itemhash = Hash.new
    item.each do |k,v|
      itemhash[k] = v[0]
    end
    return itemhash
  end

  # Remove year 0 if it exists
  def remove_year_zero(item)
    item.delete("0")
    return item
  end

  # Do some basic cleaning of item
  def basic_parsing(item)
    order_years(item).to_h
  end

  # Reorder dates
  def reorder_dates
    @output.each do |key, value|
      itemhash = Hash.new
      order_years(value).each do |k, v|
        itemhash[k] = v
      end
      @output[key] = itemhash
    end
  end

  # Get earliest and latest years in set
  def get_earliest_latest
    @output.each do |key, value|
      value.each do |k, v|
        year = k.to_i
        @earliest_year = year if year < @earliest_year
        @latest_year = year if year > @latest_year
      end
    end
    @earliest_year = @start_year if @start_year > @earliest_year
  end

  # Fill in blank years for each item
  def fill_in_blanks
    @output.each do |key, value|
      (@earliest_year...@latest_year).each do |year|
        @output[key][year.to_s] = 0 if !value[year.to_s]
      end
      remove_earlier(key, @output[key])
    end
  end

  # Remove earlier than earliest
  def remove_earlier(key, val)
    @output[key] = val.keep_if{|k, v| k.to_i >= @earliest_year}
  end

  # Add up all and get top x
  def add_all
    outputhash = Hash.new

    # Count up all values
    @output.each do |key, value|
      count = 0
      value.each{|k,v| count+= v}
      outputhash[key] = count
    end

    keeparr = Array.new
    outputhash.sort_by{|k, v| v}.reverse[0..@keys_to_format].each{|i| keeparr.push(i[0])}
    @output = @output.keep_if{|k, v| keeparr.include?(k)}
  end

  # Cut all values except certain keys
  def cut_except
    if @keys_to_format.is_a?(Integer)
      add_all
      # Get top x by overall count
    elsif @keys_to_format != "all"
      @output = @output.keep_if{|k, v| @keys_to_format.include?(k)}
    end
  end

  # Make array of all years
  def year_array
    return ['x'] +(@earliest_year..@latest_year).to_a
  end

  # Parse the output into an array that works with the js
  def parse_out(key, value)
    @formatted_out.push(([key]+value.values))
  end

  # Format outut
  def format_output
    @formatted_out.push(year_array)
    @output.each do |key, value|
      parse_out(key, value)
    end
  end

  # Preprocess the input data
  def preprocess_data
    # Remove things if needed
    if @filter_keys
      @input = @input.delete_if{|k, v| !@filter_keys.include?(k)}
    end
  end

  # Format files
  def format
    preprocess_data
    
    @input.each do |key, value|
      @output[key] = basic_parsing(value)
    end
    
    # Reorder the dates and fill in blanks
    get_earliest_latest
    fill_in_blanks
    reorder_dates
    cut_except
    
    format_output
    return JSON.pretty_generate(@formatted_out)
  end
end

file = "viz/results/country_timeline_raw.json"
file2 = "viz/results/organization_timeline_raw.json"
file3 = "viz/results/tools_timeline_raw.json"
file4 = "viz/results/topics_timeline_raw.json"
file5 = "viz/results/companies_timeline_raw.json"
messaging = ["Signal", "Whatsapp", "Telegram"]
networks = ["SSL", "proxy", "VPN", "Tor", "TLS"]
countries = ["China", "Canada", "United Kingdom", "United States", "Germany", "France", "Syria", "India", "Japan", "Korea", "Ireland", "Italy", "Mexico", "Russia", "United Arab Emirates", "Australia", "Egypt", "Pakistan", "Iran", "Saudi Arabia", "Ethiopia", "Indonesia", "Israel", "Bahrain", "Thailand"]
topics = ["security", "Surveillance", "law", "Privacy", "Censorship", "Malware"]
companies = ["Hacking Team", "FinFisher", "Blue Coat", "Gamma Group", "Verint"]
f = FormatResults.new(file5, 163, 1990, companies, nil)
puts f.format


