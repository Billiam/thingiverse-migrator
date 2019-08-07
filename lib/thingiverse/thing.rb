require 'thingiverse/resource'
require 'nokogiri'
require 'http'

module Thingiverse
  class Thing < Resource
    THING_PATH = '/things/%s'

    SCRAPE_PATH = Thingiverse::WEBHOST + '/thing:'
    SCRAPE_CACHE = 'http://webcache.googleusercontent.com/search?q=cache:https%3A%2F%2Fwww.thingiverse.com%2Fthing%3A'

    def initialize(thing)
      @thing = thing
    end

    def details
      puts "Fetching #{@thing}"

      api_data = fetch(full_path)

      api_data['ancestors'] = fetch("#{full_path}/ancestors")
      api_data['files'] = fetch("#{full_path}/files")
      api_data['category'] = Array(fetch("#{full_path}/categories")).first
      api_data['tags'] = fetch("#{full_path}/tags")

      api_data.merge(scrape)
    end

    private

    def scrape
      begin
        response = HTTP.get(scrape_path)
        # TODO: If request times out, use cache
      end

      result = {
        'images' => []
      }

      if response && response.status == 200
        doc = Nokogiri::HTML(response.body.to_s)
        result['images'] = doc.css('.gallery-photo').map {|image| image['data-full'] }.uniq.select {|url| url =~ %r{https?://[^/]+/assets/} }
      end

      result
    end

    def scrape_path
      "#{SCRAPE_PATH}#{@thing}"
    end

    def cache_path
      "#{SCRAPE_CACHE}#{@thing}"
    end

    def path
      THING_PATH % @thing
    end
  end
end
