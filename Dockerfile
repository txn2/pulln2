FROM golang:1.11.2-alpine3.8 AS builder

RUN apk update \
 && apk add git

RUN mkdir -p /go/src \
 && mkdir -p /go/bin \
 && mkdir -p /go/pkg

ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH
ENV PROJECT=$GOPATH/src/github.com/txn2/xn2

RUN mkdir -p $PROJECT

WORKDIR $PROJECT

ADD . .

# all deps should be in vendor except json-iterator
RUN go get github.com/json-iterator/go
RUN CGO_ENABLED=0 go build -tags=jsoniter -a -installsuffix cgo -o /go/bin/xn2 $PROJECT/cmd/xn2.go

FROM alpine:3.8
RUN apk --no-cache add ca-certificates

COPY --from=builder /go/bin/xn2 /bin/xn2

WORKDIR /

ENTRYPOINT ["xn2"]