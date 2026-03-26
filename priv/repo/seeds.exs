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

# Crée ou récupère l'utilisateur shdxw@shdxw.fr
case Repo.get_by(User, email: "shdxw@shdxw.fr") do
  nil ->
    %User{}
    |> User.email_changeset(%{"email" => "shdxw@shdxw.fr"})
    |> User.password_changeset(%{"password" => password, "password_confirmation" => password})
    |> User.confirm_changeset()
    |> Repo.insert!()

    IO.puts("Seed terminé : utilisateur shdxw@shdxw.fr créé")

  existing ->
    existing
    |> User.password_changeset(%{"password" => password, "password_confirmation" => password})
    |> User.confirm_changeset()
    |> Repo.update!()

    IO.puts("Seed : utilisateur shdxw@shdxw.fr mis à jour")
end

# === Shop Items ===
alias Shdxw.Shop.ShopItem

shop_items = [
  %{
    name: "Boost XP x2",
    description: "Double votre gain d'XP pendant 1 heure",
    price: 100,
    type: :boost,
    effect: "xp_multiplier_2x",
    duration_minutes: 60,
    icon: "hero-bolt",
    rarity: :rare,
    level_required: 3
  },
  %{
    name: "Boost XP x3",
    description: "Triple votre gain d'XP pendant 30 minutes",
    price: 300,
    type: :boost,
    effect: "xp_multiplier_3x",
    duration_minutes: 30,
    icon: "hero-bolt",
    rarity: :epic,
    level_required: 10
  },
  %{
    name: "Super Boost XP x5",
    description: "Quintuple votre gain d'XP pendant 15 minutes !",
    price: 1000,
    type: :boost,
    effect: "xp_multiplier_5x",
    duration_minutes: 15,
    icon: "hero-bolt",
    rarity: :legendary,
    level_required: 20
  },
  %{
    name: "Gel Streak",
    description: "Protege votre streak pendant 1 jour si vous oubliez de vous connecter",
    price: 150,
    type: :consumable,
    effect: "streak_freeze",
    duration_minutes: 1440,
    icon: "hero-shield-check",
    rarity: :rare,
    level_required: 5
  },
  %{
    name: "Bouclier Priorite",
    description: "Protege vos taches en retard pendant 1 jour",
    price: 200,
    type: :consumable,
    effect: "priority_shield",
    duration_minutes: 1440,
    icon: "hero-shield-exclamation",
    rarity: :epic,
    level_required: 8
  },
  %{
    name: "Bonus Temps",
    description: "Ajoute 5 minutes bonus a votre prochain pomodoro",
    price: 75,
    type: :consumable,
    effect: "time_warp",
    icon: "hero-clock",
    rarity: :common,
    level_required: 1
  },
  %{
    name: "Double Or",
    description: "Double votre gain d'or pendant 1 heure",
    price: 250,
    type: :boost,
    effect: "gold_multiplier_2x",
    duration_minutes: 60,
    icon: "hero-currency-dollar",
    rarity: :epic,
    level_required: 7
  }
]

for item_attrs <- shop_items do
  case Repo.get_by(ShopItem, effect: item_attrs.effect) do
    nil -> Repo.insert!(%ShopItem{} |> ShopItem.changeset(item_attrs))
    existing -> Repo.update!(ShopItem.changeset(existing, item_attrs))
  end
end

IO.puts("Seed terminé : #{length(shop_items)} items de boutique")

# === Achievements ===
alias Shdxw.Achievements.Achievement

achievements = [
  # Todos
  %{
    key: "first_todo",
    name: "Premiere Tache",
    description: "Completez votre premiere tache",
    icon: "hero-check",
    category: :todos,
    rarity: :common,
    xp_reward: 25,
    gold_reward: 10,
    condition_type: "count",
    condition_value: 1
  },
  %{
    key: "todo_10",
    name: "Productif",
    description: "Completez 10 taches",
    icon: "hero-check-badge",
    category: :todos,
    rarity: :common,
    xp_reward: 100,
    gold_reward: 50,
    condition_type: "count",
    condition_value: 10
  },
  %{
    key: "todo_50",
    name: "Machine a Taches",
    description: "Completez 50 taches",
    icon: "hero-cpu-chip",
    category: :todos,
    rarity: :rare,
    xp_reward: 300,
    gold_reward: 150,
    condition_type: "count",
    condition_value: 50
  },
  %{
    key: "todo_100",
    name: "Centurion",
    description: "Completez 100 taches",
    icon: "hero-fire",
    category: :todos,
    rarity: :epic,
    xp_reward: 750,
    gold_reward: 400,
    condition_type: "count",
    condition_value: 100
  },
  %{
    key: "todo_500",
    name: "Legende Vivante",
    description: "Completez 500 taches",
    icon: "hero-star",
    category: :todos,
    rarity: :legendary,
    xp_reward: 2000,
    gold_reward: 1000,
    condition_type: "count",
    condition_value: 500
  },

  # Streak
  %{
    key: "streak_3",
    name: "Trois Jours",
    description: "Maintenez un streak de 3 jours",
    icon: "hero-fire",
    category: :streak,
    rarity: :common,
    xp_reward: 50,
    gold_reward: 25,
    condition_type: "streak",
    condition_value: 3
  },
  %{
    key: "streak_7",
    name: "Une Semaine",
    description: "Maintenez un streak de 7 jours",
    icon: "hero-fire",
    category: :streak,
    rarity: :rare,
    xp_reward: 150,
    gold_reward: 75,
    condition_type: "streak",
    condition_value: 7
  },
  %{
    key: "streak_30",
    name: "Un Mois",
    description: "Maintenez un streak de 30 jours",
    icon: "hero-fire",
    category: :streak,
    rarity: :epic,
    xp_reward: 500,
    gold_reward: 250,
    condition_type: "streak",
    condition_value: 30
  },
  %{
    key: "streak_100",
    name: "Cent Jours",
    description: "Maintenez un streak de 100 jours !",
    icon: "hero-fire",
    category: :streak,
    rarity: :legendary,
    xp_reward: 2000,
    gold_reward: 1000,
    condition_type: "streak",
    condition_value: 100
  },

  # Pomodoro
  %{
    key: "first_pomodoro",
    name: "Premier Focus",
    description: "Completez votre premiere session pomodoro",
    icon: "hero-clock",
    category: :pomodoro,
    rarity: :common,
    xp_reward: 25,
    gold_reward: 10,
    condition_type: "count",
    condition_value: 1
  },
  %{
    key: "pomodoro_10",
    name: "Concentre",
    description: "Completez 10 sessions pomodoro",
    icon: "hero-clock",
    category: :pomodoro,
    rarity: :common,
    xp_reward: 100,
    gold_reward: 50,
    condition_type: "count",
    condition_value: 10
  },
  %{
    key: "pomodoro_50",
    name: "Zen Master",
    description: "Completez 50 sessions pomodoro",
    icon: "hero-clock",
    category: :pomodoro,
    rarity: :rare,
    xp_reward: 300,
    gold_reward: 150,
    condition_type: "count",
    condition_value: 50
  },

  # Habits
  %{
    key: "first_habit",
    name: "Bonne Habitude",
    description: "Completez votre premiere habitude",
    icon: "hero-arrow-path",
    category: :habits,
    rarity: :common,
    xp_reward: 25,
    gold_reward: 10,
    condition_type: "count",
    condition_value: 1
  },
  %{
    key: "habit_50",
    name: "Creature d'Habitude",
    description: "Completez 50 habitudes",
    icon: "hero-arrow-path",
    category: :habits,
    rarity: :rare,
    xp_reward: 300,
    gold_reward: 150,
    condition_type: "count",
    condition_value: 50
  },

  # Level
  %{
    key: "level_5",
    name: "En Route",
    description: "Atteignez le niveau 5",
    icon: "hero-arrow-trending-up",
    category: :level,
    rarity: :common,
    xp_reward: 0,
    gold_reward: 50,
    condition_type: "level",
    condition_value: 5
  },
  %{
    key: "level_10",
    name: "Double Digits",
    description: "Atteignez le niveau 10",
    icon: "hero-arrow-trending-up",
    category: :level,
    rarity: :rare,
    xp_reward: 0,
    gold_reward: 150,
    condition_type: "level",
    condition_value: 10
  },
  %{
    key: "level_25",
    name: "Quart de Siecle",
    description: "Atteignez le niveau 25",
    icon: "hero-arrow-trending-up",
    category: :level,
    rarity: :epic,
    xp_reward: 0,
    gold_reward: 500,
    condition_type: "level",
    condition_value: 25
  },

  # Shop
  %{
    key: "first_purchase",
    name: "Premier Achat",
    description: "Achetez votre premier item en boutique",
    icon: "hero-shopping-cart",
    category: :shop,
    rarity: :common,
    xp_reward: 50,
    gold_reward: 0,
    condition_type: "purchase",
    condition_value: 1
  },
  %{
    key: "big_spender",
    name: "Gros Depensier",
    description: "Depensez 1000 or au total",
    icon: "hero-banknotes",
    category: :shop,
    rarity: :rare,
    xp_reward: 200,
    gold_reward: 0,
    condition_type: "count",
    condition_value: 1000
  },

  # Secret
  %{
    key: "secret_night_owl",
    name: "Oiseau de Nuit",
    description: "Completez une tache entre 2h et 5h du matin",
    icon: "hero-moon",
    category: :secret,
    rarity: :epic,
    xp_reward: 200,
    gold_reward: 100,
    condition_type: "custom",
    condition_value: 1,
    hidden: true
  },
  %{
    key: "secret_speed_demon",
    name: "Demon de Vitesse",
    description: "Completez 5 taches en 10 minutes",
    icon: "hero-bolt",
    category: :secret,
    rarity: :epic,
    xp_reward: 300,
    gold_reward: 150,
    condition_type: "custom",
    condition_value: 5,
    hidden: true
  }
]

for achievement_attrs <- achievements do
  case Repo.get_by(Achievement, key: achievement_attrs.key) do
    nil -> Repo.insert!(%Achievement{} |> Achievement.changeset(achievement_attrs))
    existing -> Repo.update!(Achievement.changeset(existing, achievement_attrs))
  end
end

IO.puts("Seed terminé : #{length(achievements)} achievements")

# === Skins ===
Shdxw.Skins.seed_skins()
IO.puts("Seed terminé : skins")

# === Enchantments ===
Shdxw.Enchantments.seed_enchantments()
IO.puts("Seed terminé : enchantments")
