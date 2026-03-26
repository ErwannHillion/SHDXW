defmodule Shdxw.Enchantments do
  @moduledoc """
  The Enchantments context. Minecraft-style enchantment system for skins.
  Enchantments provide additional XP/gold boosts and special effects.

  Types d'enchantements:
  - Fortune: +gold% par niveau
  - Experience: +XP% par niveau
  - Sharpness: +XP% sur les todos
  - Efficiency: +XP% sur les pomodoros
  - Looting: Chance de doubler les rewards de quetes
  - Protection: Jours supplementaires de streak freeze
  - Mending: Chance de restaurer du streak
  - Thorns: XP bonus quand on complete une tache urgente
  - Fire Aspect: Multiplicateur de streak bonus
  - Luck of the Sea: Chance d'obtenir des items rares en quetes
  """

  import Ecto.Query, warn: false
  alias Shdxw.Repo
  alias Shdxw.Accounts.Scope
  alias Shdxw.Enchantments.{Enchantment, SkinEnchantment}
  alias Shdxw.Skins

  # --- Listing ---

  def list_enchantments do
    Enchantment
    |> order_by(asc: :rarity, asc: :name)
    |> Repo.all()
  end

  def list_skin_enchantments(user_skin_id) do
    from(se in SkinEnchantment,
      where: se.user_skin_id == ^user_skin_id,
      join: e in Enchantment,
      on: se.enchantment_id == e.id,
      preload: [enchantment: e],
      order_by: [asc: e.name]
    )
    |> Repo.all()
  end

  def get_equipped_enchantments(%Scope{} = scope) do
    case Skins.get_equipped_skin(scope) do
      nil ->
        []

      user_skin ->
        list_skin_enchantments(user_skin.id)
    end
  end

  # --- Enchanting ---

  def enchant_skin(%Scope{} = scope, user_skin_id, enchantment_id) do
    profile = Shdxw.Gamification.get_or_create_profile(scope)
    enchantment = Repo.get!(Enchantment, enchantment_id)
    user_skin = Repo.get_by!(Shdxw.Skins.UserSkin, id: user_skin_id, user_id: scope.user.id)
    skin = Repo.get!(Shdxw.Skins.Skin, user_skin.skin_id)

    existing = Repo.get_by(SkinEnchantment,
      user_skin_id: user_skin_id,
      enchantment_id: enchantment_id
    )

    target_level = if existing, do: existing.level + 1, else: 1
    cost = Enchantment.cost_for_level(enchantment, target_level)

    # Count current enchantments on this skin
    current_count =
      from(se in SkinEnchantment, where: se.user_skin_id == ^user_skin_id)
      |> Repo.aggregate(:count)

    skin_rarity = to_string(skin.rarity)

    cond do
      target_level > enchantment.max_level ->
        {:error, :max_level_reached}

      profile.level < enchantment.min_player_level ->
        {:error, :level_required}

      profile.gold < cost ->
        {:error, :insufficient_gold}

      existing == nil and current_count >= skin.enchantment_slots ->
        {:error, :no_slots_available}

      skin_rarity not in enchantment.compatible_rarities ->
        {:error, :incompatible_rarity}

      true ->
        {:ok, _} = Shdxw.Gamification.spend_gold(scope, cost)

        if existing do
          {:ok, updated} =
            existing
            |> SkinEnchantment.changeset(%{level: target_level})
            |> Repo.update()

          {:ok, Repo.preload(updated, :enchantment)}
        else
          {:ok, created} =
            %SkinEnchantment{user_id: scope.user.id}
            |> SkinEnchantment.changeset(%{
              user_skin_id: user_skin_id,
              enchantment_id: enchantment_id
            })
            |> Repo.insert()

          {:ok, Repo.preload(created, :enchantment)}
        end
    end
  end

  def get_enchant_cost(enchantment_id, user_skin_id) do
    enchantment = Repo.get!(Enchantment, enchantment_id)

    existing = Repo.get_by(SkinEnchantment,
      user_skin_id: user_skin_id,
      enchantment_id: enchantment_id
    )

    target_level = if existing, do: existing.level + 1, else: 1
    Enchantment.cost_for_level(enchantment, target_level)
  end

  # --- Boost Calculations ---

  def get_total_xp_boost(%Scope{} = scope) do
    enchantments = get_equipped_enchantments(scope)

    Enum.reduce(enchantments, 0, fn se, acc ->
      case se.enchantment.type do
        :experience -> acc + Enchantment.effect_at_level(se.enchantment, se.level)
        _ -> acc
      end
    end)
  end

  def get_total_gold_boost(%Scope{} = scope) do
    enchantments = get_equipped_enchantments(scope)

    Enum.reduce(enchantments, 0, fn se, acc ->
      case se.enchantment.type do
        :fortune -> acc + Enchantment.effect_at_level(se.enchantment, se.level)
        _ -> acc
      end
    end)
  end

  def get_enchantment_summary(%Scope{} = scope) do
    enchantments = get_equipped_enchantments(scope)

    Enum.map(enchantments, fn se ->
      %{
        name: se.enchantment.name,
        icon: se.enchantment.icon,
        level: se.level,
        type: se.enchantment.type,
        effect: Enchantment.effect_at_level(se.enchantment, se.level),
        roman: to_roman(se.level)
      }
    end)
  end

  defp to_roman(1), do: "I"
  defp to_roman(2), do: "II"
  defp to_roman(3), do: "III"
  defp to_roman(4), do: "IV"
  defp to_roman(5), do: "V"
  defp to_roman(n) when n > 5, do: "#{n}"

  # --- Seed Data ---

  def seed_enchantments do
    enchantments = [
      %{name: "Fortune", description: "Augmente les gains d'or.", icon: "💰", type: :fortune, max_level: 5, base_effect_value: 0, effect_per_level: 5, base_cost: 100, cost_multiplier: 1.8, min_player_level: 3, rarity: :common},
      %{name: "Experience", description: "Augmente les gains d'XP.", icon: "✨", type: :experience, max_level: 5, base_effect_value: 0, effect_per_level: 5, base_cost: 120, cost_multiplier: 1.8, min_player_level: 3, rarity: :common},
      %{name: "Sharpness", description: "Bonus XP sur les taches completees.", icon: "⚔️", type: :sharpness, max_level: 5, base_effect_value: 2, effect_per_level: 3, base_cost: 150, cost_multiplier: 2.0, min_player_level: 5, rarity: :rare},
      %{name: "Efficiency", description: "Bonus XP sur les sessions pomodoro.", icon: "⛏️", type: :efficiency, max_level: 5, base_effect_value: 2, effect_per_level: 2, base_cost: 150, cost_multiplier: 2.0, min_player_level: 5, rarity: :rare},
      %{name: "Looting", description: "Chance de doubler les rewards de quetes.", icon: "🎲", type: :looting, max_level: 3, base_effect_value: 5, effect_per_level: 5, base_cost: 300, cost_multiplier: 2.5, min_player_level: 8, rarity: :epic},
      %{name: "Protection", description: "Jours supplementaires de protection de streak.", icon: "🛡️", type: :protection, max_level: 4, base_effect_value: 0, effect_per_level: 1, base_cost: 250, cost_multiplier: 2.0, min_player_level: 10, rarity: :epic},
      %{name: "Mending", description: "Chance de restaurer 1 jour de streak perdu.", icon: "💚", type: :mending, max_level: 3, base_effect_value: 3, effect_per_level: 3, base_cost: 400, cost_multiplier: 2.5, min_player_level: 12, rarity: :epic},
      %{name: "Thorns", description: "XP bonus massif sur les taches urgentes.", icon: "🌹", type: :thorns, max_level: 3, base_effect_value: 5, effect_per_level: 10, base_cost: 500, cost_multiplier: 2.5, min_player_level: 15, rarity: :legendary},
      %{name: "Fire Aspect", description: "Multiplicateur de bonus de streak.", icon: "🔥", type: :fire_aspect, max_level: 2, base_effect_value: 10, effect_per_level: 10, base_cost: 800, cost_multiplier: 3.0, min_player_level: 20, rarity: :legendary},
      %{name: "Luck of the Sea", description: "Chance d'obtenir des items rares en quetes.", icon: "🎣", type: :luck_of_the_sea, max_level: 3, base_effect_value: 3, effect_per_level: 3, base_cost: 600, cost_multiplier: 2.5, min_player_level: 15, rarity: :legendary}
    ]

    Enum.each(enchantments, fn attrs ->
      case Repo.get_by(Enchantment, name: attrs.name) do
        nil -> %Enchantment{} |> Enchantment.changeset(attrs) |> Repo.insert!()
        existing -> existing |> Enchantment.changeset(attrs) |> Repo.update!()
      end
    end)
  end
end
