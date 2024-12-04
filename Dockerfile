FROM golang:1.23.3-alpine3.20 as builder

WORKDIR /app

# Install GCC and build dependencies
RUN apk add --no-cache gcc musl-dev

COPY . .

ARG CGO_ENABLED=1

# if build fails, try this for more verbosity:
# RUN go build -x -v -work ./cmd/goatcounter
RUN CGO_ENABLED=${CGO_ENABLED} go build -tags osusergo,netgo,sqlite_omit_load_extension \
    -o app \
    -ldflags="-X zgo.at/goatcounter/v2.Version=$(git log -n1 --format='%h_%cI') -extldflags=-static" \
    ./cmd/goatcounter

FROM alpine:3.20.0

WORKDIR /app

COPY --from=builder /app/app .

ENTRYPOINT [ "./app" ]
CMD ["help"]
