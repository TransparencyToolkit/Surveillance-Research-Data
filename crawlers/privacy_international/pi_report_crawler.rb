require 'open-uri'
require 'nokogiri'
require 'pry'
require 'json'

load 'pi_report_parser.rb'

class PiReportCrawler
  def initialize(url, doc_dir)
    @url = url
    @doc_dir = doc_dir
    @output = Array.new
  end

  # Get all pages
  def get_all_reports
    (0..11).each do |pagenum|
      html = Nokogiri::HTML.parse(open("#{@url}?page=#{pagenum}").read)
      get_reports_on_page(html)
    end
  end

  # Get a list of the reports on the page and parse
  def get_reports_on_page(html)
    reports = html.css(".reports-page-fields").css(".views-field-title").css("a").map{|a| "https://privacyinternational.org/#{a['href']}"}
    reports.each{|report| parse_report(report)}
  end

  # Parse a single report
  def parse_report(url)
    p = PiReportParser.new(url, @doc_dir)
    @output.push(p.parse)
  end

  # Generate the JSON output
  def gen_json
    return JSON.pretty_generate(@output)
  end
end

doc_dir = "dir/to/save/docs"
url = "https://privacyinternational.org/reports"
p = PiReportCrawler.new(url, doc_dir)
p.get_all_reports
File.write("raw_pi_report_data.json",  p.gen_json)
