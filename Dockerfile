FROM ruby:2.6

WORKDIR /usr/src/tv

RUN echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && wget --quiet -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

# Install basic tools
RUN apt-get update \
  && apt-get install -q -y lsof unzip wget tar openssl xvfb \
  && apt-get install -q -y google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*

RUN wget -nv https://chromedriver.storage.googleapis.com/76.0.3809.68/chromedriver_linux64.zip -O /tmp/chromedriver_linux64.zip \
  && unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin \
  && rm -f /tmp/chromedriver_linux64.zip

COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4

COPY . .

ENTRYPOINT ["/usr/local/bin/bundle", "exec", "ruby", "main.rb"]
