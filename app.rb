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

    output_directory = APP_ROOT.join('things')

    Thingiverse::Backup.new(name, output_directory).run
  end

  desc "restore", "Restore backed up data to new service"
  option :service, default: 'prusaprinters', enum: %w(prusaprinters)
  option :screenshot, required: false, type: :boolean, default: false, desc: "Save screenshots during request timeouts"
  def restore
    service = options[:service]

    if service == 'prusaprinters'
      require 'prusa'

      Prusa::Restore.new(APP_ROOT.join('things'), screenshot: options[:screenshot]).run
    end
  end
end
