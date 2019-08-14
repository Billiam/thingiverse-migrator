require 'json'
require 'prusa/parser'

module Prusa
  class Uploader
    def initialize(path, session, publish=false)
      @path = Pathname.new(File.expand_path(path))
      @session = session
      @publish = publish
    end

    def name
      thing.name
    end

    def thing
      @thing ||= Prusa::Parser.new @path.join("#{@path.basename}.json")
    end

    def run
      @session.with_screenshot do |session|
        license = thing.mapped_license

        session.goto 'https://prusaprinters.org/print/create'

        session.text_field(id: 'print-name').set thing.name
        session.textarea(id: 'summary').set thing.summary
        session.select_list(id: 'category').select thing.mapped_category
        session.textarea(id: 'content').set thing.instructions

        tag_string = thing.tags
        unless tag_string.empty?
          session.input(css: 'print-tags form input').wd.send_keys "#{tag_string} "
        end

        asset_list = thing.upload_paths

        puts "Uploading files"
        asset_list.each do |asset|
          print "."
          session.file_field(id: 'file-upload-input').set asset
          session.wait_until { session.div(class_name: 'progress-bar').exists? }
          session.wait_until { !session.div(class_name: 'progress-bar').exists? }
          sleep 3 unless asset == asset_list.last
        end
        puts ""

        license_select = session.select_list(id: 'license')
        license_select.select license
        session.wait_until do
          license_select.selected_options.map(&:text).include? license
        end

        if @publish && thing.published?
          if !session.button(text: 'Publish now').exists?
            session.div(class_name: 'form-check-switch').span(text: 'Published').click
          end
          session.button(text: 'Publish now').click
        else
          session.button(text: 'Save draft').click
        end

        edit_url = session.url

        session.wait_until do
          session.url != edit_url
        end
      end
    end
  end
end
