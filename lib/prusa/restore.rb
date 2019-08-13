require 'prusa/user'
require 'prusa/session'
require 'prusa/uploader'

module Prusa
  class Restore
    def initialize(directory, publish: false, screenshot: false, limit: 0)
      @directory = directory
      @screenshot = screenshot
      @limit = limit
      @publish = publish
    end

    def run
      cookie_path = APP_ROOT.join('cookie_jar')
      screenshot_path = @screenshot ? APP_ROOT.join('tmp') : nil

      session = Prusa::Session.new cookie_path, screenshot_path
      user_id = session.user_id
      existing_uploads = Prusa::User.new(user_id, session).prints.keys.map(&:strip)

      uploaders = Dir.glob(@directory.join('*')).sort_by do |directory|
        File.basename(directory).to_i
      end.lazy.map do |directory|
        uploader = Prusa::Uploader.new(directory, session, @publish)
        if existing_uploads.include? uploader.name.strip
          puts %Q[Skipping "#{uploader.name}"]
          next
        end

        uploader
      end.reject(&:nil?)

      if @limit
        uploaders = uploaders.take(@limit)
      end

      uploaders.each.with_index do |uploader, index|
        if index > 0
          puts "Waiting between uploads"
          sleep(10)
        end

        puts %Q[Uploading "#{uploader.name}"]
        uploader.run
        puts "Done uploading #{uploader.name}"
      end
    end
  end
end
