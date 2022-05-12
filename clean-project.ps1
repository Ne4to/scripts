Get-ChildItem -Directory -Recurse -Filter bin | Remove-Item -Recurse
Get-ChildItem -Directory -Recurse -Filter obj | Remove-Item -Recurse
Get-ChildItem -Directory -Recurse -Filter app | Remove-Item -Recurse
Get-ChildItem -Directory -Recurse -Filter node_modules | Remove-Item -Recurse


