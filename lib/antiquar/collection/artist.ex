defmodule Antiquar.Collection.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  schema "artists" do
    field :name, :string
    field :alternate_name, :string
    field :nationality, :string
    field :biography, :string
    has_many :artworks, Antiquar.Collection.Artwork
    timestamps(type: :utc_datetime)
  end

  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:name, :alternate_name, :nationality, :biography])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
