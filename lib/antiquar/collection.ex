defmodule Antiquar.Collection do
  import Ecto.Query

  alias Antiquar.Repo
  alias Antiquar.Collection.{Artist, Artwork, Category, Tag}

  def list_artworks(filters \\ %{}) do
    search = Map.get(filters, "search", "")

    Artwork
    |> join(:left, [artwork], artist in assoc(artwork, :artist))
    |> join(:left, [artwork], category in assoc(artwork, :category))
    |> join(:left, [artwork], tag in assoc(artwork, :tags))
    |> maybe_filter(:artist, Map.get(filters, "artist"))
    |> maybe_filter(:category, Map.get(filters, "category"))
    |> maybe_filter_tag(Map.get(filters, "tag"))
    |> maybe_search(search)
    |> preload([_artwork, artist, category],
      artist: artist,
      category: category,
      tags: ^from(tag in Tag, order_by: tag.name)
    )
    |> order_by([artwork], desc: artwork.inserted_at)
    |> distinct(true)
    |> Repo.all()
  end

  def list_artists, do: Repo.all(from artist in Artist, order_by: artist.name)
  def list_categories, do: Repo.all(from category in Category, order_by: category.name)
  def list_tags, do: Repo.all(from tag in Tag, order_by: tag.name)
  def artwork_count, do: Repo.aggregate(Artwork, :count)
  def get_artist!(id), do: Repo.get!(Artist, id)
  def list_artist_artworks(artist_id), do: list_artworks(%{"artist" => to_string(artist_id)})

  def artist_artwork_count(artist_id) do
    Repo.aggregate(from(artwork in Artwork, where: artwork.artist_id == ^artist_id), :count)
  end

  def create_artwork(attrs) do
    tags = find_or_create_tags(Map.get(attrs, "tag_names", ""))

    %Artwork{}
    |> Artwork.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.insert()
  end

  def change_artwork(%Artwork{} = artwork, attrs \\ %{}), do: Artwork.changeset(artwork, attrs)

  defp maybe_filter(query, _field, value) when value in [nil, ""], do: query

  defp maybe_filter(query, :artist, value),
    do: where(query, [_, artist, _, _], artist.id == ^value)

  defp maybe_filter(query, :category, value),
    do: where(query, [_, _, category, _], category.id == ^value)

  defp maybe_filter_tag(query, value) when value in [nil, ""], do: query

  defp maybe_filter_tag(query, value) do
    where(query, [_, _, _, tag], tag.id == ^value)
  end

  defp maybe_search(query, search) when search in [nil, ""], do: query

  defp maybe_search(query, search) do
    pattern = "%#{search}%"

    where(
      query,
      [artwork, artist, _category, tag],
      ilike(artwork.title, ^pattern) or ilike(artwork.title_original, ^pattern) or
        ilike(artist.name, ^pattern) or ilike(tag.name, ^pattern)
    )
  end

  defp find_or_create_tags(tag_names) do
    tag_names
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq_by(&String.downcase/1)
    |> Enum.map(fn name ->
      Repo.insert!(Tag.changeset(%Tag{}, %{name: name}),
        on_conflict: :nothing,
        conflict_target: :name
      )

      Repo.get_by!(Tag, name: name)
    end)
  end
end
