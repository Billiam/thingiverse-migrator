require 'thor'

class Migrator < Thor
  def self.banner(command, namespace = nil, subcommand = false)
    "#{command.formatted_usage(self, $thor_runner, subcommand)}"
  end
  def self.handle_argument_error(command, error, args, arity) #:nodoc:
    name = [command.ancestor_name, command.name].compact.join(" ")
    msg = "ERROR: \"#{name}\" was called with ".dup
    msg << "no arguments"               if     args.empty?
    msg << "arguments " << args.inspect unless args.empty?
    msg << "\nUsage: #{banner(command).inspect}"
    raise InvocationError, msg
  end

  desc "backup", "Back up Thingiverse data for NAME"
  option :name, required: true
  def backup
    name = options[:name]

    require 'thingiverse'

    Thingiverse.connection = Thingiverse::Connection.new(ENV['ACCESS_TOKEN'])

    output_directory = APP_ROOT.join('things')

    Thingiverse::Backup.new(name, output_directory).run
  end

  desc "restore", "Restore backed up data to new service"
  option :service, default: 'prusaprinters', enum: %w(prusaprinters)
  option :screenshot, required: false, type: :boolean, default: false, desc: "Save screenshots during request timeouts"
  option :limit, required: false, type: :numeric, default: 0, desc: "Limit print creation to this many items"
  option :publish, required: false, type: :boolean, default: false, desc: "Whether to published created prints (but only if published in source json)"
  def restore
    service = options[:service]

    if service == 'prusaprinters'
      require 'prusa'

      Prusa::Restore.new(APP_ROOT.join('things'), publish: options[:publish], screenshot: options[:screenshot], limit: options[:limit]).run
    end
  end

  desc "render_objects", "Generate stl and scad images for projects with no images"
  option :which, required: false, enum: %w(empty all), default: 'empty', desc: "Which projects should have images generated. Empty: only projects with no images. All: All projects"
  option :limit, required: false, type: :numeric, default: 0, desc: "Maximum number of images to create per project. Default 0 (unlimited)"
  def render_objects
    require 'prusa'

    Prusa::Screenshot.new(APP_ROOT.join('things'), limit: options[:limit], which: options[:which]).run
  end
end
