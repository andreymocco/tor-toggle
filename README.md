# Tor Toggle for SwiftBar

A SwiftBar plugin to control the Tor service from the macOS menu bar.  
You can start/stop Tor, check your current IP, change your identity, and update your bridge config.

## Features

- Toggle Tor service on/off
- Get current IP address via Tor
- Request a new identity (Newnym)
- Replace obfs4 bridge
- macOS system notifications

## Requirements

- macOS + [SwiftBar](https://swiftbar.app)
- [Tor](https://formulae.brew.sh/formula/tor) installed via Homebrew
- `curl` installed (usually present by default)

## Installation

1. Install Tor via Homebrew: `brew install tor`
2. Download tor-toggle.sh
3. Move it to your SwiftBar plugins directory. Default path: `~/Library/Application Support/SwiftBar/Plugins/`
4. Make it executable: `chmod +x tor-toggle.sh`
5. Check or create torrc file
6. Done! Click the plugin in your menu bar 🎉

## Notes

Works with bridges configured in torrc (e.g. obfs4)
Default paths are based on Homebrew Tor installation for Apple Silicon:

## Example torrc

To use this plugin, you need to configure Tor with control and bridge support.  
Here is a sample `torrc` file (located at `/opt/homebrew/etc/tor/torrc`):

```bash
UseBridges 1
ClientTransportPlugin obfs4 exec /opt/homebrew/bin/obfs4proxy
Bridge obfs4 100.0.0... iat-mode=0

SocksPort 9050
Log notice stdout

ControlPort 9051
CookieAuthentication 0
```

Replace the Bridge line with your own bridge obtained from https://bridges.torproject.org, or use the plugin's “Replace Bridge” action.

If the file doesn't exist, create it at: `/opt/homebrew/etc/tor/torrc`

## Author

[@andreymocco](https://github.com/andreymocco)