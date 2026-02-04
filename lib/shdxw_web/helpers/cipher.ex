defmodule ShdxwWeb.Helpers.Cipher do
  @moduledoc """
  Encodage et décodage de texte en langage runique SHDXW.

  La configuration (alphabet, séparateurs, offset) est lue depuis
  les variables d'environnement pour qu'il soit impossible de décoder
  le texte en lisant uniquement le code source.

  Variables d'environnement requises :
    - CIPHER_ALPHABET : les 16 glyphes séparés par des virgules
    - CIPHER_WORD_SEP : le séparateur de mots
    - CIPHER_CHAR_SEP : le séparateur de caractères
    - CIPHER_OFFSET   : décalage XOR appliqué à chaque octet (nombre entier)
  """

  defp config do
    alphabet =
      System.get_env("CIPHER_ALPHABET")
      |> String.split(",", trim: true)

    %{
      alphabet: alphabet,
      rune_to_index: alphabet |> Enum.with_index() |> Map.new(),
      index_to_rune: alphabet |> Enum.with_index() |> Enum.map(fn {r, i} -> {i, r} end) |> Map.new(),
      word_sep: System.get_env("CIPHER_WORD_SEP"),
      char_sep: System.get_env("CIPHER_CHAR_SEP"),
      offset: System.get_env("CIPHER_OFFSET") |> String.to_integer()
    }
  end

  @spec encode(String.t()) :: String.t()
  def encode(text) when is_binary(text) do
    cfg = config()

    text
    |> String.split(" ", trim: false)
    |> Enum.map(&encode_word(&1, cfg))
    |> Enum.join(cfg.word_sep)
  end

  @spec decode(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode(rune_text) when is_binary(rune_text) do
    cfg = config()

    try do
      result =
        rune_text
        |> String.split(cfg.word_sep)
        |> Enum.map(&decode_word(&1, cfg))
        |> Enum.join(" ")

      {:ok, result}
    rescue
      _ -> {:error, "Texte runique invalide"}
    end
  end

  @spec decode!(String.t()) :: String.t()
  def decode!(rune_text) do
    case decode(rune_text) do
      {:ok, result} -> result
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  # -- Privé --

  defp encode_word("", _cfg), do: ""

  defp encode_word(word, cfg) do
    word
    |> :binary.bin_to_list()
    |> Enum.map(&encode_byte(Bitwise.bxor(&1, cfg.offset), cfg))
    |> Enum.join(cfg.char_sep)
  end

  defp encode_byte(byte, cfg) do
    high = div(byte, 16)
    low = rem(byte, 16)
    Map.fetch!(cfg.index_to_rune, high) <> Map.fetch!(cfg.index_to_rune, low)
  end

  defp decode_word("", _cfg), do: ""

  defp decode_word(rune_word, cfg) do
    rune_word
    |> String.split(cfg.char_sep)
    |> Enum.map(&decode_rune_pair(&1, cfg))
    |> :binary.list_to_bin()
  end

  defp decode_rune_pair(pair, cfg) do
    graphemes = String.graphemes(pair)

    case graphemes do
      [high_rune, low_rune] ->
        high = Map.fetch!(cfg.rune_to_index, high_rune)
        low = Map.fetch!(cfg.rune_to_index, low_rune)
        Bitwise.bxor(high * 16 + low, cfg.offset)

      _ ->
        raise ArgumentError, "Paire de runes invalide: #{pair}"
    end
  end
end
