# Lotd

**Changelog: https://github.com/fuchsberger/lotd/blob/master/CHANGELOG.md**

This is a utility app for the mod "Legacy of the Dragonborn" and it allows to keep track of items collected for the museum. The following features are implemented:

* You can search for items that can be displayed in the museum and filter them by display, room, location and/or mod
* Counts of how many items can be found in a certain location / display / mod / room.
* Items, Locations, Mods, and Displays may link to external wiki pages to quickly look up further information
* mobile friendly interface

### On signing in you get access to the following additional features:
* create, rename, and delete characters that can collect items. When you sign in for the first time a default character is automatically created for you.
* You can select one of your characters to be the active one that is on the hunt. You may never delete your active character.
* Shows you statistics of not only how many items are available but also how many you have already collected.
* you can toggle mods you want to use for the current playthrough with this character. Mods not used in the playthrough and all their associated items / displays will be hidden from the gallery.

### Moderators can
* create / edit / delete Items, Displays, Locations, Rooms, Mods
* view list of users and their admin / moderation status
* deleting a display, location, or room does not delete associated items
* deleting a mod *does* delete associated items

### Admins can
* promote / demote users to moderators and admins

## Deployment Notes
This is a suggestion on how to get the server running in a linux (Ubuntu/Debian) production environment. Make sure to bump the version number in *mix.exs* before each update.

Always:
```shell
mix deps.get --only prodd
MIX_ENV=prod mix compile
cd assets && npm install
npm run deploy --prefix ./assets
mix phx.digest
MIX_ENV=prod mix release
MIX_ENV=prod mix ecto.migrate
sudo systemctl daemon-reload
sudo systemctl restart app_lotd.service
```

| Command                                     | When to execute                       |
| :---                                        | :---                                  |
| $ `mix deps.get --only prod`                | only if deps have changed             |
| `$ MIX_ENV=prod mix compile`                | always                                |
| `$ cd assets && npm install`                | only if npm modules changed           |
| `$ npm run deploy --prefix ./assets`        | only if assets or npm modules changed |
| `$ mix phx.digest`                          | only if assets or npm modules changed |
| `$ MIX_ENV=prod mix release`                | always                                |
| `$ MIX_ENV=prod mix ecto.migrate`           | only when database changed            |
| `$ sudo systemctl daemon-reload`            | always                                |
| `$ sudo systemctl restart app_lotd.service` | always                                |
