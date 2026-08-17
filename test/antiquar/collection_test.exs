defmodule Antiquar.CollectionTest do
  use Antiquar.DataCase

  alias Antiquar.Collection
  alias Antiquar.Collection.{Artist, Category}
  alias Antiquar.Repo

  test "filters artworks by artist, category, tag, and search" do
    artist = Repo.insert!(Artist.changeset(%Artist{}, %{name: "Yun Shouping"}))
    category = Repo.insert!(Category.changeset(%Category{}, %{name: "Landschaft"}))

    assert {:ok, artwork} =
             Collection.create_artwork(%{
               "title" => "Herbstlandschaft",
               "artist_id" => artist.id,
               "category_id" => category.id,
               "tag_names" => "Gongbi, Morgenwinde"
             })

    assert [result] = Collection.list_artworks(%{"artist" => "#{artist.id}"})
    assert result.id == artwork.id
    assert [result] = Collection.list_artworks(%{"category" => "#{category.id}"})
    assert result.id == artwork.id

    tag = Enum.find(result.tags, &(&1.name == "Morgenwinde"))
    assert [result] = Collection.list_artworks(%{"tag" => "#{tag.id}"})
    assert result.id == artwork.id

    assert [result] = Collection.list_artworks(%{"search" => "Herbst"})
    assert result.id == artwork.id
    assert [result] = Collection.list_artworks(%{"search" => "Morgenwinde"})
    assert result.id == artwork.id
  end
end
