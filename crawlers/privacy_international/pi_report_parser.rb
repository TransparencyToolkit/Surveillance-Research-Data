require 'json'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'parsefile'
require 'pdf-reader'

# A parser for Privacy International's reports
class PiReportParser
  def initialize(url, doc_dir)
    @html = Nokogiri::HTML.parse(open(url).read)
    @url = url
    @doc_dir = doc_dir
  end

  # Parses the page
  def parse
    return { organization: parse_organization,
             title: parse_title,
             date: parse_date,
             report_link: parse_report_link,
             pdf_link: parse_pdf_link,
             related_links: parse_related_links,
             description: parse_description,
             country_term: parse_country_term,
             tech_explainers: parse_tech_explainers,
             pdf_path: parse_pdf_path,
             text: ocr_report_pdf}
  end

  # Parse the PDF path
  def parse_pdf_path
    path = download_report_pdf
    return path.split("/").last if path
  end

  # The organization that wrote the report
  def parse_organization
    "Privacy International"
  end

  # Parse the title of the report
  def parse_title
    @html.css(".l-main").css("h1").text
  end

  # Parse the date of the report
  def parse_date
    date = @html.css("span.date-display-single").text
    return Date.parse(date) if date && !date.empty? 
  end

  # Link to report
  def parse_report_link
    @url
  end

  # Parse the link to the PDF report
  def parse_pdf_link
    link = @html.css("span.file").css("a").first
    return "https://privacyinternational.org#{link['href']}" if link
  end

  def parse_related_links
    @html.css(".group-left").css(".field__items").css("a").map{|a| "https://privacyinternational.org/node/#{a['href']}"}
  end

  # Parse the description text for the report
  def parse_description
    @html.css(".field__items").css("p").text
  end

  # Parse the country term
  def parse_country_term
    @html.css(".field--name-field-country-term").css("a").map{|a| a.text}
  end

  # Parse the tech explainers
  def parse_tech_explainers
    @html.css(".field--name-field-related-tech-explainers").css("a").map{|a| a.text}
  end

  # Download the report PDF and save the file path
  def download_report_pdf
    link = parse_pdf_link

    if link
      path = "#{@doc_dir}#{parse_pdf_link.split("/").last}"
      
      # Download if isn't there already
      if !File.exist?(URI.unescape(path))
        `wget --no-check-certificate -P #{@doc_dir} #{link.gsub("https", "http")}`
      end
      
      return path
    end
  end

  # OCR the document and return the text
  def ocr_report_pdf
    path = download_report_pdf
    if path
      reader = PDF::Reader.new(URI.unescape(path))
      return reader.pages.inject("") {|txt, page| txt+=page.text}
    end
  end
end
