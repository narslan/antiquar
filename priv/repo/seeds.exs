alias Antiquar.Collection.{Artist, Artwork, Category, Tag}
alias Antiquar.Repo
import Ecto.Query

defmodule Antiquar.Seeds do
  def find_or_insert(schema, changeset, attrs) do
    Repo.insert!(changeset.(struct(schema), attrs), on_conflict: :nothing, conflict_target: :name)
    Repo.get_by!(schema, name: attrs.name)
  end
end

yun =
  Antiquar.Seeds.find_or_insert(Artist, &Artist.changeset/2, %{
    name: "Yun Shouping",
    alternate_name: "Yun Nantian",
    nationality: "China",
    biography:
      "Yun Shouping war ein Maler der fruhen Qing-Zeit, besonders bekannt fur seine fein beobachteten Blumen- und Landschaftsbilder. Seine Verbindung von Farbe, kontrollierter Linie und poetischer Zuruckhaltung pragte die chinesische Blumenmalerei nachhaltig."
  })

shen =
  Antiquar.Seeds.find_or_insert(Artist, &Artist.changeset/2, %{
    name: "Shen Quan",
    nationality: "China",
    biography:
      "Shen Quan war ein Maler des 18. Jahrhunderts. Seine Darstellungen von Blumen, Vogeln und Insekten verbinden genaue Naturbeobachtung mit der dekorativen Klarheit der Gongbi-Malerei."
  })

Repo.update_all(from(artist in Artist, where: artist.id == ^yun.id),
  set: [
    biography:
      "Yun Shouping war ein Maler der fruhen Qing-Zeit, besonders bekannt fur seine fein beobachteten Blumen- und Landschaftsbilder. Seine Verbindung von Farbe, kontrollierter Linie und poetischer Zuruckhaltung pragte die chinesische Blumenmalerei nachhaltig."
  ]
)

Repo.update_all(from(artist in Artist, where: artist.id == ^shen.id),
  set: [
    biography:
      "Shen Quan war ein Maler des 18. Jahrhunderts. Seine Darstellungen von Blumen, Vogeln und Insekten verbinden genaue Naturbeobachtung mit der dekorativen Klarheit der Gongbi-Malerei."
  ]
)

landscape = Antiquar.Seeds.find_or_insert(Category, &Category.changeset/2, %{name: "Landschaft"})

bird_and_flower =
  Antiquar.Seeds.find_or_insert(Category, &Category.changeset/2, %{name: "Blumen und Vogel"})

study = Antiquar.Seeds.find_or_insert(Category, &Category.changeset/2, %{name: "Studie"})

for name <- ["Gongbi", "Morgenwinde", "Tinte und Farbe", "Albumblatt", "Fruehe Qing"] do
  Antiquar.Seeds.find_or_insert(Tag, &Tag.changeset/2, %{name: name})
end

for work <- [
      %{
        title: "Herbstlandschaft",
        title_original: "Qiu jing tu",
        date_display: "um 1680",
        medium: "Tinte und Farbe auf Papier",
        location: "Mappe A, Blatt 12",
        description: "Kleines Albumblatt mit einer offenen Flusslandschaft.",
        artist_id: yun.id,
        category_id: landscape.id,
        tags: ["Albumblatt", "Tinte und Farbe", "Fruehe Qing"]
      },
      %{
        title: "Morgenwinden und Schmetterling",
        date_display: "18. Jahrhundert",
        medium: "Farbe auf Seide",
        location: "Mappe B, Blatt 4",
        description: "Gongbi-Studie mit botanischem Schwerpunkt.",
        artist_id: shen.id,
        category_id: bird_and_flower.id,
        tags: ["Gongbi", "Morgenwinde", "Tinte und Farbe"]
      },
      %{
        title: "Studie eines bluhenden Zweigs",
        date_display: "undatiert",
        medium: "Tinte auf Papier",
        location: "Mappe C, Blatt 9",
        description: "Vorlage fur eine spatere Blumenkomposition.",
        artist_id: yun.id,
        category_id: study.id,
        tags: ["Gongbi", "Albumblatt"]
      }
    ] do
  tags = Enum.map(work.tags, &Repo.get_by!(Tag, name: &1))

  if Repo.get_by(Artwork, title: work.title) == nil do
    %Artwork{}
    |> Artwork.changeset(Map.drop(work, [:tags]))
    |> Ecto.Changeset.put_assoc(:tags, tags)
    |> Repo.insert!()
  end
end
