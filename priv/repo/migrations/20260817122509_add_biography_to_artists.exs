defmodule Antiquar.Repo.Migrations.AddBiographyToArtists do
  use Ecto.Migration

  def change do
    alter table(:artists) do
      add :biography, :text
    end
  end
end
