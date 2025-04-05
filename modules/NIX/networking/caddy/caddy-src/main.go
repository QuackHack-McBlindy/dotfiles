// This file is copied from:
// https://github.com/caddyserver/caddy/blob/82c356f2548ca62b75f76104bef44915482e8fd9/cmd/caddy/main.go#L21-L25

//  1. Copy this file (main.go) into a new folder
//  2. Edit the imports below to include the modules you want plugged in
//  3. Run `go mod init caddy`
//  4. Run `go install` or `go build` - you now have a custom binary!
//
// Or you can use xcaddy which does it all for you as a command:
// https://github.com/caddyserver/xcaddy
package main

import (
	caddycmd "github.com/caddyserver/caddy/v2/cmd"

	// plug in Caddy modules here
	_ "github.com/caddyserver/caddy/v2/modules/standard"
	_ "github.com/greenpau/caddy-security" // Caddy-security plugin
	_ "github.com/caddy-dns/duckdns" // DuckDNS Plugin
)

func main() {
	caddycmd.Main()
}
