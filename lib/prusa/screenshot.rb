module Prusa
  class Screenshot
    def initialize(path, limit:, which:)
      @path = path
      @limit = limit
      @filter_projects = which
    end

    def run
      Dir.glob(@path.join('*')).map do |folder|
        Pathname.new(folder)
      end.sort_by do |folder|
        folder.basename.to_s.to_i
      end.each do |folder|
        parser = Prusa::Parser.new(folder.join("#{folder.basename}.json"))

        if @filter_projects == 'empty'
          next if parser.images.any?
        end

        files = (parser.scads + parser.stls)

        output_files = files.map do |file|
          [file.basename.sub_ext(file.extname + '.render.png').to_s, file]
        end.to_h

        # already_rendered = parser.renders
        already_rendered = []
        to_render = output_files.keys - already_rendered

        if @limit > 0
          count_to_render = [0, @limit - already_rendered.count].max
          to_render = to_render.first(count_to_render)
        end

        to_render.each do |output_name|
          render(output_files[output_name], folder.join(output_name))
        end

        if to_render.any?
          parser.renders = (already_rendered + to_render)

          parser.save
        end
      end
    end

    def render(file, output_file)
      puts "Rendering #{file.dirname.basename.join(file.basename)}"

      options = ['--colorscheme', 'Nature', '-o', output_file.to_s, '--imgsize=1280,960']

      if File.extname(file).downcase == '.stl'
        blank_scad = APP_ROOT.join('assets', 'blank.scad')
        system 'xvfb-run', '-a', 'openscad', blank_scad.to_s, *options, '-D', "import(\"#{file}\");"
      else
        system 'xvfb-run', '-a', 'openscad', file.to_s, *options
      end
    end
  end
end
