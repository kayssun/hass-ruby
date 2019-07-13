# hass-client, Ruby client for HomeAssistant

hass-client is a simple Ruby client for the HomeAssistant API.

The idea was to have a client which has actual classes for the available devices. This way, you can inspect objects and see your possible actions. It works for the available services but not yet for all states.

## Installation

Install the gem via 

```bash
gem install hass-client
```

or put it in your Gemfile

```ruby
gem 'hass-client'
```

## Usage

### Command line client

The command line client allows to send simple commands to your HomeAssistant instance.

You need to set the environment variables HASS_HOST, HASS_PORT, and HASS_TOKEN. To get your API token, log in to your HomeAssistant instance and go your profile (the initials in the sidebar). Then scroll down and ceate an authentication token.

To set these variables in the shell use:
```
export HASS_HOST=your-hostname.example.com
export HASS_PORT=8123
export HASS_TOKEN=abcdef
export HASS_TLS=1
```

HASS_SSL=1 ensures a TLS (SSL) connection to your server.

```bash
hass-send <entity_id> <service>
```

for example:

```bash
hass-send light.living_room turn_on
hass-send light.living_room turn_off
hass-send light.living_room toggle
```

Always use the full object name (with the dot) so the client can derive the object type.

### Library

A simple script the toogle a light switch might look like this:

```ruby
require 'hass/client'

client = Hass::Client.new('localhost', 8123, 'api_token')

light = client.light('light.living_room')
light.toggle
```

You can get a list of your available device types (domains) via

```ruby
pp(client.domains.map { |domain| domain['domain'] })
```

You can also get a list of your available entity ids via

```ruby
pp(client.states.map {|state| state['entity_id']} )
```

After initializing the client, you can instantiate the available classes directly. You need to provide the client object to be able to use them:

```ruby
client = Hass::Client.new('localhost', 8123, 'api_token')
mediaplayer = Hass::MediaPlayer.new('media_player.yamaha_receiver')
mediaplayer.client = client
pp mediaplayer.attributes
mediaplayer.select_source(source: 'HDMI1')
```

## Caveats

To make multiple calls to client.domains faster, the result is cached. If you have a longer running application, you will have to set @domains to nil to re-request the data. Other requests are not cached at all and this might significantly slow down access to multiple devices.
