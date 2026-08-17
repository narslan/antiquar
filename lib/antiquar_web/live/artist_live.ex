defmodule AntiquarWeb.ArtistLive do
  use AntiquarWeb, :live_view

  alias Antiquar.Collection

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    artist = Collection.get_artist!(id)

    {:ok,
     socket
     |> assign(:artist, artist)
     |> assign(:artwork_count, Collection.artist_artwork_count(artist.id))
     |> assign(:page_title, artist.name)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section class="border-b border-stone-200 bg-[#eeece4]">
        <div class="mx-auto max-w-5xl px-5 py-8 sm:px-8 sm:py-12">
          <.link
            navigate={~p"/"}
            class="inline-flex items-center gap-2 text-sm text-emerald-800 transition hover:text-emerald-950"
          >
            <.icon name="hero-arrow-left" class="size-4" /> Sammlung
          </.link>
          <p class="mt-8 text-xs font-semibold uppercase tracking-[0.18em] text-emerald-800">
            Kunstlerprofil
          </p>
          <h1 class="mt-3 font-serif text-5xl text-stone-900">{@artist.name}</h1>
          <p :if={@artist.alternate_name} class="mt-2 text-lg text-stone-600">
            {@artist.alternate_name}
          </p>
          <p :if={@artist.nationality} class="mt-1 text-sm uppercase tracking-[0.12em] text-stone-500">
            {@artist.nationality}
          </p>
        </div>
      </section>

      <section class="mx-auto grid max-w-5xl gap-10 px-5 py-10 sm:px-8 md:grid-cols-[minmax(0,1fr)_13rem] md:py-14">
        <div>
          <h2 class="font-serif text-2xl text-stone-900">Biografie</h2>
          <p class="mt-4 max-w-2xl text-base leading-8 text-stone-700">
            {@artist.biography || "Zu diesem Kunstler wurde noch keine Biografie erfasst."}
          </p>
        </div>
        <div class="border-l-2 border-emerald-800 pl-5">
          <p class="font-serif text-4xl text-stone-900">{@artwork_count}</p>
          <p class="mt-1 text-xs uppercase tracking-[0.12em] text-stone-500">Werke erfasst</p>
          <.link
            id="artist-artworks-link"
            navigate={~p"/artists/#{@artist}/artworks"}
            class="mt-6 inline-flex items-center gap-2 bg-emerald-800 px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-emerald-950"
          >
            Werke ansehen <.icon name="hero-arrow-right" class="size-4" />
          </.link>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
