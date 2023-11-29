# Lotd

**Changelog: https://github.com/fuchsberger/lotd/blob/master/CHANGELOG.md**

This is a utility app for the mod "Legacy of the Dragonborn" and it allows to find out what items can be found at a searched location or in a given mod. The following features are implemented:

* You can search for items that can be displayed in the museum and filter them by display, room, location and/or mod
* Items, Locations, Mods may link to external wiki pages to quickly look up further information
* mobile friendly interface

### On signing in you get access to the following additional features:
* you can toggle mods you want to exclude or include from the search. By default all officially supported mods are selected.

## Deployment Notes
This is a suggestion on how to get the server running in a linux (Ubuntu/Debian) production environment. Make sure to bump the version number in *mix.exs* before each update.

```shell
mix deps.get --only prod
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
