defmodule AntiquarWeb.ArtistArtworksLive do
  use AntiquarWeb, :live_view

  alias Antiquar.Collection

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    artist = Collection.get_artist!(id)

    {:ok,
     socket
     |> assign(:artist, artist)
     |> assign(:artworks, Collection.list_artist_artworks(artist.id))
     |> assign(:page_title, "Werke von #{artist.name}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section class="border-b border-stone-200 bg-[#eeece4]">
        <div class="mx-auto max-w-[90rem] px-5 py-8 sm:px-8 sm:py-12">
          <.link
            navigate={~p"/artists/#{@artist}"}
            class="inline-flex items-center gap-2 text-sm text-emerald-800 transition hover:text-emerald-950"
          >
            <.icon name="hero-arrow-left" class="size-4" /> {@artist.name}
          </.link>
          <p class="mt-8 text-xs font-semibold uppercase tracking-[0.18em] text-emerald-800">
            Werkverzeichnis
          </p>
          <h1 class="mt-3 font-serif text-4xl text-stone-900 sm:text-5xl">
            Werke von {@artist.name}
          </h1>
        </div>
      </section>

      <section class="mx-auto max-w-[90rem] px-5 py-8 sm:px-8 sm:py-12">
        <div id="artist-artwork-grid" class="grid gap-x-5 gap-y-9 sm:grid-cols-2 xl:grid-cols-3">
          <article
            :for={artwork <- @artworks}
            id={"artist-artwork-#{artwork.id}"}
            class="group min-w-0"
          >
            <div class="aspect-[4/3] overflow-hidden bg-[#ded9ca]">
              <img
                :if={artwork.image_url not in [nil, ""]}
                src={artwork.image_url}
                alt={artwork.title}
                class="size-full object-cover transition duration-500 group-hover:scale-[1.02]"
              />
              <div
                :if={artwork.image_url in [nil, ""]}
                class="grid size-full place-items-center bg-[#d4ddcb] font-serif text-5xl text-emerald-950/65"
              >
                {artwork_initial(artwork.title)}
              </div>
            </div>
            <div class="mt-3 border-l-2 border-emerald-800 pl-3">
              <h2 class="font-serif text-xl leading-tight text-stone-900">{artwork.title}</h2>
              <p :if={artwork.date_display} class="mt-1 text-sm text-stone-600">
                {artwork.date_display}
              </p>
              <div :if={artwork.tags != []} class="mt-3 flex flex-wrap gap-1.5">
                <span
                  :for={tag <- artwork.tags}
                  class="border border-stone-300 px-2 py-0.5 text-xs text-stone-600"
                >{tag.name}</span>
              </div>
            </div>
          </article>
          <div
            :if={@artworks == []}
            id="empty-artist-artworks"
            class="col-span-full border border-dashed border-stone-300 px-6 py-16 text-center text-sm text-stone-500"
          >
            Noch keine Werke erfasst.
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp artwork_initial(title), do: title |> String.trim() |> String.first() |> String.upcase()
end
