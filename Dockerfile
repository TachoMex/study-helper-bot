FROM ruby:3.2.2-slim

RUN  apt update && \
     apt install -y build-essential libpq-dev python3 python3-pip ffmpeg && \
     rm -rf /var/lib/apt/lists/* && \
     pip3 install yt-dlp  --break-system-packages && \
     mkdir /app

WORKDIR /app

COPY Gemfile .
COPY Gemfile.lock .
RUN  gem install bundler && \
     bundle install


COPY . .

CMD ["sh", "entrypoint.sh"]
