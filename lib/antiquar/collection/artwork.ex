defmodule Antiquar.Collection.Artwork do
  use Ecto.Schema
  import Ecto.Changeset

  schema "artworks" do
    field :title, :string
    field :title_original, :string
    field :date_display, :string
    field :medium, :string
    field :description, :string
    field :source_url, :string
    field :image_url, :string
    field :location, :string
    belongs_to :artist, Antiquar.Collection.Artist
    belongs_to :category, Antiquar.Collection.Category
    many_to_many :tags, Antiquar.Collection.Tag, join_through: "artwork_tags", on_replace: :delete
    timestamps(type: :utc_datetime)
  end

  def changeset(artwork, attrs) do
    artwork
    |> cast(attrs, [
      :title,
      :title_original,
      :date_display,
      :medium,
      :description,
      :source_url,
      :image_url,
      :location,
      :artist_id,
      :category_id
    ])
    |> validate_required([:title])
    |> foreign_key_constraint(:artist_id)
    |> foreign_key_constraint(:category_id)
  end
end
