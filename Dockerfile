FROM golang:1.16-alpine as builder
WORKDIR /build
COPY . .
RUN CGO_ENABLED=0 go build -a -o render-plantuml ./cmd/render-plantuml

FROM think/plantuml:1.2020.5
# Enables README support, etc. in Github Packages. See: https://docs.github.com/en/packages/guides/about-github-container-registry
LABEL org.opencontainers.image.source https://github.com/racklet/render-plantuml-action

COPY --from=builder /build/render-plantuml /
ENTRYPOINT ["/render-plantuml"]
