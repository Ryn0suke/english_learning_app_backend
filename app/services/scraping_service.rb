require 'nokogiri'
require 'open-uri'
require 'uri'

class ScrapingService
  def self.scrape_data(keyword)
    base_url = 'https://eikaiwa.dmm.com'#/search/?keyword='
    encoded_keyword = URI.encode_www_form_component(keyword)
    search_url = "#{base_url}/uknow/search/?keyword=#{encoded_keyword}"

    all_urls = get_page_urls(search_url)

    results = all_urls.map do |url|
        english_url = "#{base_url}#{url}"
        get_english_phrase(english_url)
    end
    results
  end

  private

  def self.get_page_urls(url)
    document = Nokogiri::HTML(URI.open(url))
    url_list = document.css('div.container.main-top div.container-padding.border-all-solid.link h2 a').map do |link|
      link['href']
    end
    url_list
  end

  def self.get_english_phrase(url)
    document = Nokogiri::HTML(URI.open(url))
    answer_components = document.css("div.q-detail-curator-answer").map do |component|
        component
    end

    answer = answer_components.map do |component|
        answers_japanese = component.css("ul.q-detail-curator-answer-translation li").map do |answer|
            answer.text.strip
        end

        explanations = component.css("div.q-detail-explanation.answer-content.active.markup-content").map do |explanation|
            explanation.text.strip
        end
        [answers_japanese, explanations]
    end
    answer
  end
end
