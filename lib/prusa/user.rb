module Prusa
  class User
    attr_reader :session

    def initialize(user_id, session)
      @user_id = user_id
      @session = session
    end

    def prints
      session.goto(format('https://www.prusaprinters.org/social/%s/prints', @user_id))
      # Load all drafts
      draft_loader = session.element(class: 'load-more-drafts')
      while draft_loader.text =~ /load more drafts/i
        draft_loader.button(class: 'btn').click
      end

      # Load all public prints
      loader = session.element(css: 'load-more-infinity')
      while !(loader.text =~ /all prints loaded/i || loader.text =~ /no prints found/i)
        session.scroll.to(:bottom)
        session.wait_until do
          text = loader.text

          text =~ /load more/i || text =~ /all prints loaded/i
        end
      end

      session.links(css: '.print-list-item a.link').map do |link|
        [link.element(class: 'name').text, link.href]
      end.to_h
    end
  end
end
