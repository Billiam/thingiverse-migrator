require 'json'

module Prusa
  class Uploader
    attr_reader :session

    CATEGORY_MAP = {
      '3D Printing'            => 'Other Accessories',
      '3D Printer Accessories' => 'Other Accessories',
      '3D Printer Extruders'   => '3D Printers - Upgrades',
      '3D Printer Parts'       => '3D Printers - Upgrades',
      '3D Printers'            => 'Other Accessories',
      '3D Printing Tests'      => 'Test models',
      'Art'                    => 'Other Art & Designs',
      '2D Art'                 => '2D Plates & Logos',
      'Art Tools'              => 'Tools',
      'Coins & Badges'         => 'Other Art & Designs',
      'Interactive Art'        => 'Other Art & Designs',
      'Math Art'               => 'Other Art & Designs',
      'Scans & Replicas'       => 'Historical context',
      'Sculptures'             => 'Sculptures',
      'Signs & Logos'          => '2D Plates & Logos',
      'Fashion'                => 'Other Fashion Accessories',
      'Accessories'            => 'Other Fashion Accessories',
      'Bracelets'              => 'Other Fashion Accessories',
      'Costume'                => 'Cosplay & Costumes in general',
      'Earrings'               => 'Other Fashion Accessories',
      'Glasses'                => 'Other Fashion Accessories',
      'Jewelry'                => 'Other Fashion Accessories',
      'Keychains'              => 'Other Fashion Accessories',
      'Rings'                  => 'Other Fashion Accessories',
      'Gadgets'                => 'Other Gadgets',
      'Audio'                  => 'Audio',
      'Camera'                 => 'Photo & Video',
      'Computer'               => 'Computers',
      'Mobile Phone'           => 'Portable devices',
      'Tablet'                 => 'Portable devices',
      'Video Games'            => 'Other Toys & Games',
      'Hobby'                  => 'Other Ideas',
      'Automotive'             => 'Mechanical parts',
      'DIY'                    => 'Other Ideas',
      'Electronics'            => 'Electronics',
      'Music'                  => 'Audio',
      'R/C Vehicles'           => 'RC & Robotics',
      'Robotics'               => 'RC & Robotics',
      'Sport & Outdoors'       => 'Outdoor Sports',
      'Household'              => 'Other House equipment',
      'Bathroom'               => 'Bathroom',
      'Containers'             => 'Organizers',
      'Decor'                  => 'Home Decor',
      'Household Supplies'     => 'Other House equipment',
      'Kitchen & Dining'       => 'Kitchen',
      'Office'                 => 'Office',
      'Organization'           => 'Organizers',
      'Outdoor & Garden'       => 'Outdoor & Garden',
      'Pets'                   => 'Pets',
      'Replacement Parts'      => 'Mechanical parts',
      'Learning'               => 'Objects for learning',
      'Biology'                => 'Objects for learning',
      'Engineering'            => 'Objects for learning',
      'Math'                   => 'Objects for learning',
      'Physics & Astronomy'    => 'Objects for learning',
      'Models'                 => 'Other Toys & Games',
      'Animals'                => 'Animals',
      'Buildings & Structures' => 'Architecture & Urbanism',
      'Creatures'              => 'Action Figures & Statues',
      'Food & Drink'           => 'Other Toys & Games',
      'Model Furniture'        => 'Other Toys & Games',
      'Model Robots'           => 'Action Figures & Statues',
      'People'                 => 'Action Figures & Statues',
      'Props'                  => 'Other Toys & Games',
      'Vehicles'               => 'Vehicles',
      'Tools'                  => 'Tools',
      'Hand Tools'             => 'Tools',
      'Machine Tools'          => 'Tools',
      'Parts'                  => 'Mechanical parts',
      'Tool Holders & Boxes'   => 'Organizers',
      'Toys & Games'           => 'Other Toys & Games',
      'Chess'                  => 'Board games',
      'Construction Toys'      => 'Building Toys',
      'Dice'                   => 'Board games',
      'Games'                  => 'Other Toys & Games',
      'Mechanical Toys'        => 'Building Toys',
      'Playsets'               => 'Other Toys & Games',
      'Puzzles'                => 'Puzzles & Brain-teasers',
      'Toy & Game Accessories' => 'Other Toys & Games',
      'Other'                  => 'Other Ideas',
    }

    LICENSE_MAP = {
      'Creative Commons - Attribution' => 'Creative Commons — Attribution',
      'Creative Commons - Attribution - Share Alike' => 'Creative Commons — Attribution  — Share Alike',
      'Creative Commons - Attribution - No Derivatives' => 'Creative Commons — Attribution — NoDerivates',
      'Creative Commons - Attribution - Non-Commercial' => 'Creative Commons — Attribution  — Noncommercial',
      'Creative Commons - Attribution - Non-Commercial - Share Alike' => 'Creative Commons — Attribution  — Noncommercial  —  Share Alike',
      'Creative Commons - Attribution - Non-Commercial - No Derivatives' => 'Creative Commons — Attribution  — Noncommercial  —  No Derivates',
      'Creative Commons - Public Domain Dedication' => 'Creative Commons — Public Domain',
      'GNU - GPL' => 'Creative Commons — Attribution  — Share Alike',
      'GNU - LGPL' => 'Creative Commons — Attribution  — Share Alike',
      'BSD License' => 'Creative Commons — Attribution  — Share Alike',
    }

    WARNING_LICENSE = ['GNU - GPL', 'GNU - LGPL', 'BSD License']

    @warned_license = false

    def self.check_license(license)
      return if @warned_license

      if WARNING_LICENSE.include? thing_license
        puts "Some projects use licenses not supported by PrusaPrinters (BSD or GPL)"
        puts "If you continue, these will be created as Creative Commons - Attribution - Share Alike"
        puts "Do you wish to continue with this change? [y/N]"

        result = gets.chomp
        if result !~ /y(es)?/i
          puts "Aborting PrusaPrinters migration"
          exit(false)
        end

        @warned_license = true
      end
    end

    def initialize(path, session)
      @path = Pathname.new(File.expand_path(path))
      @session = session
    end

    def name
      parsed_json["name"]
    end

    def mapped_category
      CATEGORY_MAP[parsed_json['category']['name'].strip]
    end

    def mapped_license
      thing_license = parsed_json['license'].strip
      self.class.check_license(thing_license)
      LICENSE_MAP[thing_license]
    end

    def summary
      description = parsed_json['description']
      remixed_from = parsed_json['ancestors']

      if remixed_from&.any?
        remix_markdown = remixed_from.map do |source|
          sprintf("[%<name>s](%<url>s) by [%<creator>s](%<creator_url>s)",
      {
              name: source['name'],
              url: source['public_url'],
              creator: source['creator']['name'],
              creator_url: source['creator']['public_url']
            }
          )
        end.join("\n")

        description += "\n\n### Remixed From: \n\n#{remix_markdown}"
      end

      description
    end

    def tags
      parsed_json['tags'].map { |tag| tag['name'].gsub(/[^a-z0-9]/i, '') }.compact.reject(&:empty?).join(' ')
    end

    def upload_paths

    end

    def instructions
      parsed_json['details_parts'].reject do |section|
        section['type'] == 'summary'
      end.flat_map do |section|
        Array(section['data']).map do |subsection|
          content = subsection['notes'] || subsection['content']

          next unless content

          title = subsection['title']
          if title
            content = "## #{title.sub('Post-processing (optional)', 'Post-processing')}\n\n#{content}"
          end

          content
        end
      end.compact.join("\n\n")
    end

    def run
      session.goto 'https://prusaprinters.org/print/create'

      session.text_field(id: 'print-name').set parsed_json['name']
      session.textarea(id: 'summary').set summary
      session.select_list(id: 'category').select mapped_category
      session.textarea(id: 'content').set instructions

      tag_string = tags
      unless tag_string.empty?
        session.input(css: 'print-tags form input').wd.send_keys "#{tag_string} "
      end

      session.button(text: 'Save draft').click
    end

    private

    def parsed_json
      @parsed_data ||= begin
        json_path = @path.join("#{@path.basename}.json")
        JSON.parse(File.read(json_path))
      end
    end
  end
end
