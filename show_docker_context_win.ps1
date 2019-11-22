[CmdletBinding()]
param(
  [int]$MinSizeKb = 10,
  [switch]$ShowStat
)

Set-StrictMode -Version 'Latest'

'
# escape=`
FROM build-context-win

COPY . /build-context
WORKDIR /build-context
' | docker build -t build-context-win:tmp -f - . | Out-Null

docker run --rm --env MIN_SIZE_KB=$MinSizeKb --env SHOW_STAT=$ShowStat build-context-win:tmp


