module Prusa
  class User
    attr_reader :session

    def initialize(user_id, session)
      @user_id = user_id
      @session = session
    end

    def prints
      session.goto(format('https://www.prusaprinters.org/social/%s/prints', @user_id))
      loader = session.element(css: 'load-more-infinity')
      while loader.text !~ /all prints loaded/i
        session.scroll.to(:bottom)
        session.wait_until do
          text = loader.text

          text =~ /load more/i || text =~ /all prints loaded/i
        end
      end

      session.links(css: '.print-list-item a.link').map do |link|
        [link.href, link.element(class: 'name').text]
      end
    end
  end
end
