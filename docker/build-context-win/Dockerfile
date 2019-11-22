FROM mcr.microsoft.com/dotnet/framework/sdk:4.7.2-windowsservercore-ltsc2019

WORKDIR /app
COPY script.ps1 .
WORKDIR /build-context
CMD powershell -File /app/script.ps1