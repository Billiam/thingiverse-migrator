module Prusa
  class Screenshot
    def initialize(path, render_all=false)
      @path = path
      @render_all = render_all
    end

    def run
      Dir.glob(@path.join('*')).map do |folder|
        Pathname.new(folder)
      end.sort_by do |folder|
        folder.basename.to_s.to_i
      end.each do |folder|
        parser = Prusa::Parser.new(folder.join("#{folder.basename}.json"))

        next if parser.rendered_images?

        if @render_all
          files = (parser.scads + parser.stls)
        else
          if parser.has_image?
            next
          end
          files = (parser.scads + parser.stls).first(1)
        end

        rendered_files = files.map do |file|
          render(file).basename.to_s
        end

        parser.renders = rendered_files
        parser.save
      end
    end

    def render(file)
      puts "Rendering #{file.dirname.basename.join(file.basename)}"

      output_file = file.sub_ext(file.extname + '.render.png')

      options = ['--colorscheme', 'Nature', '-o', output_file.to_s, '--imgsize=1280,960']

      if File.extname(file).downcase == '.stl'
        blank_scad = APP_ROOT.join('assets', 'blank.scad')
        system 'xvfb-run', '-a', 'openscad', blank_scad.to_s, *options, '-D', "import(\"#{file}\");"
      else
        system 'xvfb-run', '-a', 'openscad', file.to_s, *options
      end

      output_file
    end
  end
end
