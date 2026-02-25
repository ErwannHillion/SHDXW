# Script for populating the database. You can run it as:

#     mix run priv/repo/seeds.exs

# Inside the script, you can read and write to any of your
# repositories directly:

#     Shdxw.Repo.insert!(%Shdxw.SomeSchema{})

# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Shdxw.Repo
alias Shdxw.Accounts.User

# Récupère le mot de passe depuis la variable d'environnement
password = System.fetch_env!("SHDXW_PASSWORD")

# Crée l'utilisateur shdxw@shdxw.fr avec le mot de passe fourni
%User{}
|> User.email_changeset(%{"email" => "shdxw@shdxw.fr"})
|> User.password_changeset(%{"password" => password, "password_confirmation" => password})
|> User.confirm_changeset()
|> Repo.insert!(
  on_conflict: :nothing,
  conflict_target: :email
)

IO.puts("Seed terminé : utilisateur shdxw@shdxw.fr créé")
