FROM golang:alpine AS builder

RUN apk update && apk add --no-cache git

ENV USER=gouser
ENV UID=1000

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

WORKDIR /application

COPY . /application

RUN go get -d -v

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /output/go-simple-health

FROM scratch

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /output/go-simple-health /go-simple-health

USER gouser:gouser

EXPOSE 8080

ENTRYPOINT ["/go-simple-health"]

