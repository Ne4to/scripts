FROM mcr.microsoft.com/dotnet/framework/sdk:4.8

WORKDIR /app
COPY script.ps1 .
WORKDIR /build-context
CMD powershell -File /app/script.ps1