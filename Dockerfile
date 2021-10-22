FROM elixir:alpine AS build

WORKDIR /usr/src/is_mart_open_api

ENV MIX_ENV prod

RUN mix do local.hex --force, local.rebar --force

COPY mix.exs mix.lock ./
RUN mix do deps.get, deps.compile

COPY . .
RUN mix do compile, release

FROM alpine:latest AS app

WORKDIR /usr/local

RUN apk add --no-cache ncurses-libs tzdata libstdc++ openssl
ENV TZ Asia/Seoul

COPY --from=build /usr/src/is_mart_open_api/_build/prod/rel/is_mart_open_api .

EXPOSE 4000
ENTRYPOINT ["bin/is_mart_open_api"]
CMD ["start"]