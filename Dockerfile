FROM ruby:2.6

WORKDIR /usr/src/tv

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4

COPY . .

ENTRYPOINT ["/usr/local/bin/bundle", "exec", "ruby", "main.rb"]
