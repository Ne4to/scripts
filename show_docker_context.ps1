"
FROM busybox
COPY . /build-context
WORKDIR /build-context
#CMD find .
CMD ls -lSRh
" | docker build -t build-context -f - .
docker run --rm build-context