require 'watir'

module Prusa
  class Session
    def initialize(cookie_path = nil, screenshot_path)
      @cookie_path = cookie_path
      @screenshot_path = screenshot_path
    end

    def session
      @session ||= begin
        session = Watir::Browser.new :chrome, headless: true, options: { args: ['--disable-gpu', '--no-sandbox'] }
        puts "Setting up session"
        session.goto 'https://www.prusaprinters.org'
        restore_cookies(session)
        session.goto 'https://auth.prusaprinters.org'
        restore_auth_cookies(session)

        session
      end
    end

    def with_screenshot
      yield session
    rescue Watir::Exception::UnknownObjectException, Watir::Wait::TimeoutError
      session.driver.save_screenshot(@screenshot_path.join(Time.now.strftime("%Y%m%d-%H%M%S.png"))) if @screenshot_path

      raise
    end

    def user_id(is_retry=false)
      session.goto 'https://www.prusaprinters.org'

      session.wait_until do
        logged_in? || logged_out?
      end

      # Is user already logged in?
      if logged_in?
        menu = session.element(css: '.navbar-item.dropdown app-avatar', visible: true).parent(class_name: 'dropdown', tag_name: 'li')
        menu.click

        menu.link(class: 'dropdown-item', text: /My Profile/i).href.match(%r[social/(\d+)])[1]
      elsif !is_retry
        login
        user_id(true)
      end
    end

    def login
      puts "Logging in"

      session.button(text: /Login/).click

      session.wait_until do
        (session.url =~ %r{auth\.prusaprinters\.org} && auth_logged_out?) || (session.url =~ %r{^https://www.prusaprinters.org} && logged_in?)
      end

      if session.url =~ %r{auth\.prusaprinters\.org}
        username = request_email
        password = request_password

        session.text_field(id: 'id_email').set username
        session.text_field(id: 'id_password').set password
        session.button(text: 'Sign in').click

        session.wait_until do
          session.text =~ /credentials are invalid/ || logged_in?
        end

        if session.text =~ /credentials are invalid/
          raise "Incorrect credentials"
        end
      end

      save_cookies

      session.goto 'https://auth.prusaprinters.org'

      save_auth_cookies
    end

    private

    def logged_in?
      session.element(css: '.nav-block app-avatar').exists?
    end

    def logged_out?
      session.button(text: /Login/).exists?
    end

    def auth_logged_out?
      session.button(text: 'Sign in').exists?
    end

    def load_cookies(session, cookies)
      session.cookies.load cookies if File.readable?(cookies)
    end

    def restore_auth_cookies(session)
      return unless @cookie_path

      load_cookies(session, @cookie_path.join('prusa-auth.yml'))
    end

    def save_auth_cookies
      session.cookies.save @cookie_path.join('prusa-auth.yml') if @cookie_path
    end

    def restore_cookies(session)
      return unless @cookie_path

      load_cookies(session, @cookie_path.join('prusa.yml'))
    end

    def save_cookies
      session.cookies.save @cookie_path.join('prusa.yml') if @cookie_path
    end

    def request_email
      puts ""
      puts "Enter your PrusaPrinters email address:"
      print "> "
      gets.chomp
    end

    def request_password
      require 'io/console'
      puts ""
      puts "Enter your PrusaPrinters password:"
      puts "  Password will not be saved (but cookie will be)"
      print "> "
      IO.console.getpass
    end
  end
end
