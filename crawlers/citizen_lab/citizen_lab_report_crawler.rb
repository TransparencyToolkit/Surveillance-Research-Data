require 'open-uri'
require 'nokogiri'
require 'pry'
require 'json'

load 'citizen_lab_report_parser.rb'

class CitizenLabReportCrawler
  def initialize(url)
    @url = url
    @output = Array.new
  end

  # Crawl each report
  def crawl_all_reports
    (1..15).each do |pagenum|
      html = Nokogiri::HTML.parse(open("#{@url}page/#{pagenum}/").read)
      get_reports_on_page(html)
    end
  end

  # Get all the reports on the page
  def get_reports_on_page(html)
    reports = html.css(".entry-title").css("a").map{|ele| ele['href']}
    reports.each {|report| parse_report(report)}
  end

  # Parse the report
  def parse_report(link)
    puts "Parsing Report: #{link}"
    c = CitizenLabReportParser.new(link)
    @output.push(c.parse)
  end

  # Generate a JSON of output
  def gen_json
    JSON.pretty_generate(@output)
  end
end

c = CitizenLabReportCrawler.new("https://citizenlab.org/category/research-news/reports-briefings/")
c.crawl_all_reports
File.write("raw_citizenlab_report_data.json", c.gen_json)
