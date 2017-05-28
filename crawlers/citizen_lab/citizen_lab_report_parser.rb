require 'json'
require 'open-uri'
require 'nokogiri'
require 'pry'

class CitizenLabReportParser
  def initialize(url)
    @html = Nokogiri::HTML.parse(open(url).read)
    @url = url
  end

  # Parse the report
  def parse
    return  {
      report_link: parse_report_link,
      organization: parse_organization,
      title: parse_title,
      date: parse_date,
      authors: parse_authors,
      related_links: parse_related_links,
      pdf_link: parse_pdf_link,
      description: parse_description,
      text: parse_text,
      tags: parse_tags
    }
  end

  # Parse the URL
  def parse_report_link
    @url
  end

  # The organization that wrote the report
  def parse_organization
    "Citizen Lab"
  end

  # Parse the title to the report
  def parse_title
    @html.css("h2.entry-title").text
  end

  # Parse the posting date
  def parse_date
    date = @html.css("div#singlecontent").css("i").first.text
    return Date.parse(date) if date && !date.empty?
  end

  # Get the authors of the report, if listed
  def parse_authors
    poss_authors = @html.css("h3")+@html.css("div.entry-content").css("p").css("strong")
    authors = poss_authors.select{|ele| ele.text.include?("By")}
    if authors && !authors.empty? && authors.first.text.include?("*")
      return authors.first.text.gsub("By: ", "").gsub("By ", "").gsub("and ", "").gsub("**", "").gsub("&","").split(",*")
    else
      return authors.first.text.gsub("By: ", "").gsub("By ", "").gsub("and ", "").split(", ") if authors && !authors.empty?
    end
  end

  # Get links to media coverage and similar
  def parse_related_links
    return (@html.css("div.entry-content").css("p").css("a").map{|link| link['href']}.compact.reject{|link| !link.include?("http")}-parse_pdf_link).uniq
  end

  # Get an array of PDF links
  def parse_pdf_link
    @html.css("div.entry-content").css("p").css("a").map{|link| link['href']}.compact.reject{|link| !link.include?("http")}.select{|link| link.include?(".pdf")}.uniq
  end

  # Get the description/short intro to the docs
  def parse_description
    poss_descriptions = @html.css("div.entry-content").css("p").select do |par|
      to_ignore = ["Tagged", "Categories:", "By:", "Media Coverage", "By "]
      (!par.to_html.include?('<strong>') &&
       !par.text.gsub(par.css("a").text, "").empty? &&
       !(/\w/!~par.text) &&
       !to_ignore.any?{|term| par.text.include?(term)})
    end
    return poss_descriptions.first.text if poss_descriptions && !poss_descriptions.empty?
  end

  # Get the full text of the entry
  def parse_text
    @html.css("div.entry-content").text
  end

  # Parse the tags in the report
  def parse_tags
    poss_tags = @html.css("p").select{|ele| ele.text.include?("Tagged")}
    poss_tags.first.text.gsub("Tagged: ", "").split(", ") if poss_tags && !poss_tags.empty? 
  end
end
