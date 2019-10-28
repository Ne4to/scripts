[CmdletBinding()]
param(
  [switch]$NoSort
)

Set-StrictMode -Version 'Latest'

'
FROM ubuntu

WORKDIR /app
# RUN echo ''#!/bin/bash \n\
#     if [ $NO_SORT == "True" ]; then \n\
#       du -abhSc; \n\
#     else \n\
#       du -abhSc | sort -h; \n\
#     fi \n'' >> /app/size.sh

RUN echo ''#!/bin/bash \n\
    result=$(du -abhSc0) \n\
    if [ $NO_SORT != "True" ]; then \n\
      echo $result | sort -h; \n\
    fi \n'' >> /app/size.sh


COPY . /build-context
WORKDIR /build-context
ENTRYPOINT ["/bin/bash", "/app/size.sh"]
' | docker build -t build-context -f - . | Out-Null

docker run --rm --env NO_SORT=$NoSort build-context