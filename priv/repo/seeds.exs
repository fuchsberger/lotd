# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Lotd.Repo.insert!(%Lotd.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Lotd.Accounts

{:ok, user} = Accounts.create_user(%{ nexus_id: 811039, nexus_name: "Sekhmet13" })
Accounts.update_user(user, %{ admin: true, moderator: true })

{:ok, user} = Accounts.create_user(%{ nexus_id: 31179975, nexus_name: "Pickysaurus" })
Accounts.update_user(user, %{ admin: true, moderator: true })

{:ok, user} = Accounts.create_user(%{ nexus_id: 2846158, nexus_name: "icecreamassassin" })
Accounts.update_user(user, %{ admin: true, moderator: true })
