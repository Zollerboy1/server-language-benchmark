FROM swift:latest AS builder

WORKDIR /usr/src/app

COPY . .

RUN swift build -c release

FROM swift:latest AS runner

WORKDIR /usr/bin

COPY --from=builder /usr/src/app/.build/release/ServerBenchmark /usr/bin/ServerBenchmark

EXPOSE 8080

CMD [ "/usr/bin/ServerBenchmark" ]
