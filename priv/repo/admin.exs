# Script for initializing a superuser. You can run it as:
# "mix run priv/repo/admin.exs"

alias Lotd.Repo
alias Lotd.Accounts.User

User
|> Repo.get(811039)
|> User.changeset(%{ admin: true, moderator: true })
|> Repo.update()
