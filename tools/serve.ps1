# Minimal static file server for local preview (no Node/Python required)
param([int]$Port = 4173)

$root = Split-Path -Parent $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()
Write-Output "Serving $root at http://localhost:$Port/"

$mime = @{
  ".html" = "text/html; charset=utf-8"
  ".css"  = "text/css; charset=utf-8"
  ".js"   = "application/javascript; charset=utf-8"
  ".svg"  = "image/svg+xml"
  ".png"  = "image/png"
  ".jpg"  = "image/jpeg"
  ".jpeg" = "image/jpeg"
  ".webp" = "image/webp"
  ".ico"  = "image/x-icon"
  ".json" = "application/json"
  ".woff2"= "font/woff2"
  ".mp4"  = "video/mp4"
}

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $reqPath = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
    if ($reqPath -eq "/") { $reqPath = "/index.html" }
    $file = Join-Path $root ($reqPath -replace "/", "\").TrimStart("\")
    $resolved = [System.IO.Path]::GetFullPath($file)
    if ($resolved.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase) -and (Test-Path $resolved -PathType Leaf)) {
      $bytes = [System.IO.File]::ReadAllBytes($resolved)
      $ext = [System.IO.Path]::GetExtension($resolved).ToLower()
      if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
      $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $ctx.Response.Close()
  } catch {
    Write-Output "ERR: $_"
  }
}
