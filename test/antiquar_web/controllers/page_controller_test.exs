defmodule AntiquarWeb.PageControllerTest do
  use AntiquarWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Antiquar.Collection.{Artist, Artwork, Category}
  alias Antiquar.Collection
  alias Antiquar.Repo

  test "GET / renders the collection LiveView", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Meine Sammlung"
  end

  test "artist profile links to a separate artist works page", %{conn: conn} do
    artist =
      Repo.insert!(Artist.changeset(%Artist{}, %{name: "Yun Shouping", biography: "Biografie"}))

    category = Repo.insert!(Category.changeset(%Category{}, %{name: "Landschaft"}))

    artwork =
      Repo.insert!(
        Artwork.changeset(%Artwork{}, %{
          title: "Herbstlandschaft",
          artist_id: artist.id,
          category_id: category.id
        })
      )

    {:ok, profile_view, _html} = live(conn, ~p"/artists/#{artist}")
    assert has_element?(profile_view, "#artist-artworks-link")

    {:ok, works_view, _html} = live(conn, ~p"/artists/#{artist}/artworks")
    assert has_element?(works_view, "#artist-artwork-grid")
    assert has_element?(works_view, "#artist-artwork-#{artwork.id}")
  end

  test "stores an uploaded artwork image locally", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    view |> element("#add-artwork") |> render_click()

    upload =
      file_input(view, "#artwork-form", :artwork_image, [
        %{name: "studie.jpg", content: "image data", type: "image/jpeg"}
      ])

    render_upload(upload, "studie.jpg")

    view
    |> form("#artwork-form", artwork: %{title: "Hochgeladene Studie"})
    |> render_submit()

    [artwork] = Collection.list_artworks(%{"search" => "Hochgeladene"})
    file_path = upload_path(artwork.image_url)
    on_exit(fn -> File.rm(file_path) end)

    assert artwork.image_url =~ "/uploads/artworks/"
    assert File.exists?(file_path)
  end

  defp upload_path(image_url) do
    Path.join([
      :antiquar |> :code.priv_dir() |> to_string(),
      "static",
      String.trim_leading(image_url, "/")
    ])
  end
end
