# Apple Music to Slack

> Update your Slack status with the current song playing via the Music.app.

## Setup

1. Setup the slack app:

    1. Create a new app https://api.slack.com/apps?new_app=1 providing a name and
	     selecting the desired Slack Workspace that you’re going to run Apple Music to Slack on;

    2. Under “Add features and functionality” select the “Permissions” section;

    3. Scroll down to "User Token Scopes" and add `users.profile:write`;

    4. Scroll up to the top of the page and click “Install App to Workspace”;

    5. Copy the `OAuth Access Token`, this will be used as the `SLACK_SECRET_TOKEN`;

2.  Clone the repo & compile with `swift build -c release`;

3.  Run the binary with the env var `SLACK_SECRET_TOKEN` set to your `OAuth Access Token`.

    Either:

    - Run via shell:

      ```sh
      export SLACK_SECRET_TOKEN=xoxp-11111-11111-11111-111111111111
      while true; do
          ./.build/release/apple-music-to-slack
          # Slack rates limit at anything less than 5 requests/second
          sleep 10
      done
      ```

    - Run via `launchd`:

      ```sh
      cp ./.build/release/apple-music-to-slack /usr/local/bin/
      cp me.frizlab.apple-music-to-slack.plist ~/Library/LaunchAgents
      launchctl bootstrap "gui/$UID" ~/Library/LaunchAgents/me.frizlab.apple-music-to-slack.plist

      # To disable the launchd job
      launchctl bootout "gui/$UID" ~/Library/LaunchAgents/me.frizlab.apple-music-to-slack.plist
      ```

4.  Success! 🎶

## Prior Art

- <https://github.com/sbdchd/apple-music-to-slack>
- <https://github.com/ocxo/slacktunes>
- <https://github.com/josegonzalez/python-slack-tunes>
