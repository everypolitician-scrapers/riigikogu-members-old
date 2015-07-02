
# Fetch member information from riigikogu.ee

require 'json'
require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'open-uri/cached'
require 'pry'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def date_from(t)
  return if t.to_s.empty?
  Date.parse(t).to_s rescue ''
end

def scrape_list(url)
  noko = noko_for(url)
  table = noko.at_xpath('.//h2[contains(., "Riigikogu liikmed")]/following::table')
  table.css('tr').drop(1).each do |tr|
    tds = tr.css('td')
    next if tds[1].text.to_s.gsub(/[[:space:]]+/, '').empty?
    name, party, notes = tds[0].text.strip.split(/[\(\)]/, 3).map { |t| t.gsub(/[[:space:]]+/, ' ').strip }
    binding.pry if tr.text.include? 'Rahumägi'
    data = { 
      name: name,
      party: party,
      birth_date: date_from(tds[1].text.strip),
      term: 12,
      notes: notes,
    }
    puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

scrape_list('http://www.riigikogu.ee/tutvustus-ja-ajalugu/riigikogu-ajalugu/xii-riigikogu-koosseis/juhatus-ja-liikmed/')
