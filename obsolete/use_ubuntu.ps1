$Env:DOCKER_TLS_VERIFY = "1"
$Env:DOCKER_HOST = "tcp://10.255.2.83:2376"
$Env:DOCKER_CERT_PATH = "C:\Users\asosnin\.docker\machine\machines\ubuntu"
$Env:DOCKER_MACHINE_NAME = "ubuntu"
$Env:COMPOSE_CONVERT_WINDOWS_PATHS = "true"
# Run this command to configure your shell:
# & "C:\Program Files\Docker\Docker\Resources\bin\docker-machine.exe" env --shell powershell ubuntu | Invoke-Expression
