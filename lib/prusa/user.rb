module Prusa
  class User
    def initialize(user_id, session)
      @user_id = user_id
      @session = session
    end

    def prints
      puts "Looking for existing uploads"

      @session.with_screenshot do |session|
        session.goto(format('https://www.prusaprinters.org/social/%s/prints', @user_id))
        # Load all drafts
        draft_loader = session.element(class: 'load-more-drafts')
        while draft_loader.text =~ /load more drafts/i
          draft_loader.button(class: 'btn').click
        end

        loader = session.element(css: 'load-more-infinity')

        wait_condition = ->(text) { text =~ /load more/i || text =~ /all prints loaded/i || text.strip.empty? }

        while !wait_condition.call(loader.text)
          session.scroll.to(:bottom)
          session.wait_until do
            wait_condition.call(loader.text)
          end
        end

        session.links(css: '.print-list-item a.link').map do |link|
          [link.element(class: 'name').text, link.href]
        end.to_h
      end
    end
  end
end
