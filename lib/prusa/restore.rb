require 'prusa/user'
require 'prusa/session'
require 'prusa/uploader'

module Prusa
  class Restore
    def initialize(directory, screenshot=false)
      @directory = directory
      @screenshot = screenshot
    end

    def run
      cookie_path = APP_ROOT.join('cookie_jar')
      screenshot_path = @screenshot ? APP_ROOT.join('tmp') : nil

      session = Prusa::Session.new cookie_path, screenshot_path
      user_id = session.user_id
      existing_uploads = Prusa::User.new(user_id, session).prints.keys.map(&:strip)

      directories = Dir.glob(@directory.join('*')).sort_by do |directory|
        File.basename(directory).to_i
      end.first(5)

      directories.each do |directory|
        uploader = Prusa::Uploader.new(directory, session)
        if existing_uploads.include? uploader.name.strip
          # assume already uploaded
          puts %Q[Skipping "#{uploader.name}"]
        else
          puts %Q[Uploading "#{uploader.name}"]
          uploader.run
          puts "Done"

          unless directory == directories.last
            puts "Waiting between uploads"
            sleep(10)
          end
        end
      end
    end
  end
end
