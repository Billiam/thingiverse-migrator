require 'prusa/user'
require 'prusa/session'
require 'prusa/uploader'

module Prusa
  class Restore
    def initialize(directory)
      @directory = directory
    end

    def run
      session = Prusa::Session.new APP_ROOT.join('cookie_jar')
      user_id = session.user_id
      existing_uploads = Prusa::User.new(user_id, session.session).prints.keys.map(&:strip)

      Dir.glob(@directory.join('*')).first(3).each do |directory|

        uploader = Prusa::Uploader.new(directory, session.session)
        if existing_uploads.include? uploader.name.strip
          # assume already uploaded
          puts %Q[Skipping "#{uploader.name}"]
        else
          puts %Q[Uploading "#{uploader.name}"]
          uploader.run
          puts "Done, waiting between uploads"
          sleep(10)
        end
      end
    end
  end
end
