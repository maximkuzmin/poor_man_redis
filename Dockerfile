FROM elixir:1.11.2
# install Phoenix
RUN   mix local.hex --force \
  && mix local.rebar --force \
  && mix archive.install hex phx_new 1.5.8 

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && apt-get update -qq \
  && apt-get install -y inotify-tools nodejs

WORKDIR /app⏎