defmodule Antiquar.Repo.Migrations.CreateCollectionCatalog do
  use Ecto.Migration

  def change do
    create table(:artists) do
      add :name, :string, null: false
      add :alternate_name, :string
      add :nationality, :string
      timestamps(type: :utc_datetime)
    end

    create unique_index(:artists, [:name])

    create table(:categories) do
      add :name, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:categories, [:name])

    create table(:tags) do
      add :name, :string, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:tags, [:name])

    create table(:artworks) do
      add :title, :string, null: false
      add :title_original, :string
      add :date_display, :string
      add :medium, :string
      add :description, :text
      add :source_url, :string
      add :image_url, :string
      add :location, :string
      add :artist_id, references(:artists, on_delete: :nilify_all)
      add :category_id, references(:categories, on_delete: :nilify_all)
      timestamps(type: :utc_datetime)
    end

    create index(:artworks, [:artist_id])
    create index(:artworks, [:category_id])

    create table(:artwork_tags, primary_key: false) do
      add :artwork_id, references(:artworks, on_delete: :delete_all), null: false
      add :tag_id, references(:tags, on_delete: :delete_all), null: false
    end

    create unique_index(:artwork_tags, [:artwork_id, :tag_id])
    create index(:artwork_tags, [:tag_id])
  end
end
