# Hubot script for sending actions feed

It will fetch actions feed every 1 minute.

## Instalation

From your hubot source code folder:

```bash
curl https://raw.github.com/morgoth/hubot-trello_actions/master/src/scripts/trello_actions.coffee > scripts/trello_actions.coffee
```

Add `node-trello` to your `package.json` as dependency

You will need authentication token from Trello.

Get one from here (replace key):

```
https://trello.com/1/authorize?key=substitutewithyourapplicationkey&name=Hubot-TrelloActions&expiration=never&response_type=token
```

Set config variables:

* HUBOT_TRELLO_KEY (You will find yours at https://trello.com/1/appKey/generate)
* HUBOT_TRELLO_TOKEN
* HUBOT_TRELLO_BOARDS (You can specify more than one by separating them by comma)
* HUBOT_TRELLO_NOTIFY_ROOM (optional, defaults to campfire room)

## Copyright

Copyright (c) Wojciech Wnętrzak, released under the MIT license.
