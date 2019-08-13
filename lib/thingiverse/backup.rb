require 'json'
require 'http'

require 'thingiverse/user'
require 'thingiverse/thing'

module Thingiverse
  class Backup
    def initialize(username, directory)
      @username = username
      if directory.is_a? String
        directory = Pathname.new(directory)
      end

      @directory = directory
    end

    def run
      things = Thingiverse::User.new(@username).things

      things.each do |thing_data|
        thing = thing_data['id'].to_s
        directory = @directory.join(thing)

        FileUtils.mkdir_p directory

        json_path = directory.join("#{thing}.json")

        if File.exists? json_path
          puts "Skipping json fetch"
          thing_data = JSON.parse(File.read(json_path))
        else
          thing_data = Thingiverse::Thing.new(thing).details
          File.write(json_path, JSON.pretty_generate(thing_data))
        end

        downloads = thing_data['images'].map do |url|
          [URI.parse(url).path.split('/').last, url]
        end

        files = thing_data['files'].map do |file|
          [file['name'], file['public_url']]
        end

        step_images = thing_data['details_parts'].flat_map do |section|
          section['data']&.flat_map do |subsection|
            subsection['image']
          end
        end.compact

        downloads.concat files, step_images

        puts "Downloading #{downloads.count} files for #{thing}" if downloads.any?
        downloads.each do |filename, url|
          print "."

          path = directory.join(filename)
          if File.exists? path
            puts "Skipping download #{path}"
            next
          end

          response = HTTP.follow(max_hops: 3).get(url)
          File.open(path, 'wb') do |file|
            response.body.each do |chunk|
              file.write(chunk)
            end
          end
        end
        puts ""
      end
    end
  end
end
