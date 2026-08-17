defmodule AntiquarWeb.CollectionLive do
  use AntiquarWeb, :live_view

  alias Antiquar.Collection
  alias Antiquar.Collection.Artwork

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Sammlung")
     |> assign(:show_form, false)
     |> allow_upload(:artwork_image,
       accept: ~w(.jpg .jpeg .png .webp),
       max_entries: 1,
       max_file_size: 10_000_000,
       auto_upload: true
     )
     |> assign_catalog()
     |> assign_form()}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    filters = Map.take(params, ["search", "artist", "category", "tag"])

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> assign(:artworks, Collection.list_artworks(filters))}
  end

  @impl true
  def handle_event("toggle-form", _params, socket) do
    {:noreply, assign(socket, :show_form, !socket.assigns.show_form)}
  end

  def handle_event("filter", %{"filter" => filters}, socket) do
    filters = Map.reject(filters, fn {_key, value} -> value == "" end)
    {:noreply, push_patch(socket, to: ~p"/?#{filters}")}
  end

  def handle_event("validate", %{"artwork" => params}, socket) do
    changeset = Collection.change_artwork(%Artwork{}, params)
    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"artwork" => params}, socket) do
    {params, uploaded_paths} = attach_uploaded_image(socket, params)

    case Collection.create_artwork(params) do
      {:ok, artwork} ->
        {:noreply,
         socket
         |> put_flash(:info, "#{artwork.title} wurde aufgenommen.")
         |> assign(:show_form, false)
         |> assign_catalog()
         |> assign_form()
         |> push_patch(to: ~p"/")}

      {:error, changeset} ->
        Enum.each(uploaded_paths, &File.rm/1)
        {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <section class="border-b border-stone-200 bg-[#eeece4]">
        <div class="mx-auto max-w-[90rem] px-5 py-10 sm:px-8 sm:py-14">
          <div class="flex flex-col justify-between gap-8 md:flex-row md:items-end">
            <div>
              <p class="text-xs font-semibold uppercase tracking-[0.18em] text-emerald-800">
                Archiv fur ostasiatische Kunst
              </p>
              <h1 class="mt-3 font-serif text-4xl text-stone-900 sm:text-5xl">Meine Sammlung</h1>
              <p class="mt-3 max-w-xl text-sm leading-6 text-stone-600">
                Werke, Studien und ihre materiellen Spuren an einem durchsuchbaren Ort.
              </p>
            </div>
            <div class="flex items-center gap-5 border-l border-stone-300 pl-5">
              <div>
                <p class="font-serif text-3xl text-stone-900">{@artwork_count}</p>
                <p class="text-xs uppercase tracking-[0.12em] text-stone-500">Werke</p>
              </div>
              <button
                id="add-artwork"
                type="button"
                phx-click="toggle-form"
                class="grid size-11 place-items-center bg-emerald-800 text-white transition hover:bg-emerald-950"
                title="Werk aufnehmen"
                aria-label="Werk aufnehmen"
              >
                <.icon name="hero-plus" class="size-5" />
              </button>
            </div>
          </div>
        </div>
      </section>

      <section
        :if={@show_form}
        id="artwork-form-panel"
        class="border-b border-emerald-950 bg-emerald-900 text-white"
      >
        <div class="mx-auto max-w-[90rem] px-5 py-8 sm:px-8">
          <div class="mb-6 flex items-center justify-between">
            <h2 class="font-serif text-2xl">Werk aufnehmen</h2>
            <button
              id="close-artwork-form"
              type="button"
              phx-click="toggle-form"
              class="grid size-9 place-items-center border border-emerald-700 transition hover:bg-emerald-800"
              title="Schliessen"
              aria-label="Schliessen"
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>
          <.form
            for={@form}
            id="artwork-form"
            phx-change="validate"
            phx-submit="save"
            class="grid gap-x-5 gap-y-4 md:grid-cols-2 xl:grid-cols-4"
          >
            <.input field={@form[:title]} type="text" label="Titel" class="catalog-input" />
            <.input
              field={@form[:title_original]}
              type="text"
              label="Originaltitel"
              class="catalog-input"
            />
            <.input
              field={@form[:artist_id]}
              type="select"
              label="Kunstler"
              prompt="Nicht zugeordnet"
              options={option_list(@artists)}
              class="catalog-input"
            />
            <.input
              field={@form[:category_id]}
              type="select"
              label="Kategorie"
              prompt="Nicht zugeordnet"
              options={option_list(@categories)}
              class="catalog-input"
            />
            <.input
              field={@form[:date_display]}
              type="text"
              label="Datierung"
              placeholder="z. B. 1680-1690"
              class="catalog-input"
            />
            <.input
              field={@form[:medium]}
              type="text"
              label="Technik / Material"
              class="catalog-input"
            />
            <.input
              field={@form[:location]}
              type="text"
              label="Aufbewahrungsort"
              class="catalog-input"
            />
            <.input
              field={@form[:tag_names]}
              type="text"
              label="Tags"
              placeholder="Blumen, Gongbi, Studienblatt"
              class="catalog-input"
            />
            <div class="fieldset mb-2 md:col-span-2">
              <label for={@uploads.artwork_image.ref}>
                <span class="label mb-1">Bilddatei</span>
                <.live_file_input upload={@uploads.artwork_image} class="catalog-input" />
              </label>
              <p class="mt-1 text-xs text-emerald-100">JPG, PNG oder WebP, maximal 10 MB</p>
              <p :for={entry <- @uploads.artwork_image.entries} class="mt-1 text-xs text-emerald-100">
                {entry.client_name}
              </p>
              <p
                :for={error <- upload_errors(@uploads.artwork_image)}
                class="mt-1 text-xs text-red-200"
              >
                {upload_error_message(error)}
              </p>
              <p :for={entry <- @uploads.artwork_image.entries} class="mt-1 text-xs text-red-200">
                <span :for={error <- upload_errors(@uploads.artwork_image, entry)}>{upload_error_message(
                  error
                )}</span>
              </p>
            </div>
            <.input
              field={@form[:image_url]}
              type="url"
              label="Bild-URL"
              class="catalog-input md:col-span-2"
            />
            <.input
              field={@form[:source_url]}
              type="url"
              label="Quellen-URL"
              class="catalog-input md:col-span-2"
            />
            <.input
              field={@form[:description]}
              type="textarea"
              label="Notizen"
              class="catalog-input min-h-24 md:col-span-3"
            />
            <div class="flex items-end">
              <button
                id="save-artwork"
                type="submit"
                class="flex h-10 w-full items-center justify-center gap-2 bg-[#f2efe5] px-4 text-sm font-semibold text-emerald-950 transition hover:bg-white"
              >
                <.icon name="hero-check" class="size-4" /> Speichern
              </button>
            </div>
          </.form>
        </div>
      </section>

      <section class="mx-auto grid max-w-[90rem] gap-8 px-5 py-8 sm:px-8 lg:grid-cols-[15rem_minmax(0,1fr)]">
        <aside aria-label="Sammlung filtern" class="lg:border-r lg:border-stone-200 lg:pr-8">
          <div class="mb-5 flex items-center justify-between">
            <h2 class="font-serif text-xl text-stone-900">Entdecken</h2>
            <.link
              :if={has_active_filters?(@filters)}
              id="clear-filters"
              patch={~p"/"}
              class="text-xs font-semibold text-emerald-800 hover:text-emerald-950"
            >Zurucksetzen</.link>
          </div>
          <.form
            for={to_form(@filters, as: :filter)}
            id="collection-filters"
            phx-change="filter"
            class="space-y-4"
          >
            <.input
              field={to_form(@filters, as: :filter)[:search]}
              type="search"
              label="Suche"
              placeholder="Titel oder Kunstler"
              class="filter-input"
            />
            <.input
              field={to_form(@filters, as: :filter)[:artist]}
              type="select"
              label="Kunstler"
              prompt="Alle Kunstler"
              options={option_list(@artists)}
              class="filter-input"
            />
            <.input
              field={to_form(@filters, as: :filter)[:category]}
              type="select"
              label="Kategorie"
              prompt="Alle Kategorien"
              options={option_list(@categories)}
              class="filter-input"
            />
            <.input
              field={to_form(@filters, as: :filter)[:tag]}
              type="select"
              label="Schlagwort"
              prompt="Alle Schlagworter"
              options={option_list(@tags)}
              class="filter-input"
            />
          </.form>
        </aside>

        <div>
          <div class="mb-5 flex items-baseline justify-between border-b border-stone-200 pb-3">
            <p class="text-sm text-stone-500">{length(@artworks)} Ergebnisse</p>
            <p class="text-xs uppercase tracking-[0.12em] text-stone-500">Neuzugange zuerst</p>
          </div>
          <div id="artwork-grid" class="grid gap-x-5 gap-y-9 sm:grid-cols-2 xl:grid-cols-3">
            <article :for={artwork <- @artworks} id={"artwork-#{artwork.id}"} class="group min-w-0">
              <div class="aspect-[4/3] overflow-hidden bg-[#ded9ca]">
                <img
                  :if={artwork.image_url not in [nil, ""]}
                  src={artwork.image_url}
                  alt={artwork.title}
                  class="size-full object-cover transition duration-500 group-hover:scale-[1.02]"
                />
                <div
                  :if={artwork.image_url in [nil, ""]}
                  class="grid size-full place-items-center bg-[linear-gradient(135deg,#e7e1cf_0%,#c7d3c0_100%)] font-serif text-5xl text-emerald-950/65"
                >
                  {artwork_initial(artwork.title)}
                </div>
              </div>
              <div class="mt-3 border-l-2 border-emerald-800 pl-3">
                <h3 class="font-serif text-xl leading-tight text-stone-900">{artwork.title}</h3>
                <.link
                  :if={artwork.artist}
                  navigate={~p"/artists/#{artwork.artist}"}
                  class="mt-1 block text-sm text-stone-600 transition hover:text-emerald-800 hover:underline"
                >
                  {artwork.artist.name}
                </.link>
                <p :if={!artwork.artist} class="mt-1 text-sm text-stone-600">
                  Kunstler nicht zugeordnet
                </p>
                <p :if={artwork.date_display} class="mt-1 text-xs text-stone-500">
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
              id="empty-collection"
              class="col-span-full border border-dashed border-stone-300 px-6 py-16 text-center"
            >
              <.icon name="hero-magnifying-glass" class="mx-auto size-6 text-stone-400" />
              <p class="mt-3 font-serif text-xl text-stone-800">Keine Werke gefunden</p>
              <p class="mt-1 text-sm text-stone-500">
                Passe die Filter an oder nimm ein neues Werk auf.
              </p>
            </div>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp assign_catalog(socket) do
    assign(socket,
      artists: Collection.list_artists(),
      categories: Collection.list_categories(),
      tags: Collection.list_tags(),
      artwork_count: Collection.artwork_count()
    )
  end

  defp assign_form(socket),
    do: assign(socket, :form, to_form(Collection.change_artwork(%Artwork{})))

  defp option_list(records), do: Enum.map(records, &{&1.name, &1.id})

  defp has_active_filters?(filters), do: Enum.any?(filters, fn {_key, value} -> value != "" end)

  defp artwork_initial(title) do
    title
    |> String.trim()
    |> String.first()
    |> String.upcase()
  end

  defp attach_uploaded_image(socket, params) do
    uploaded_paths =
      consume_uploaded_entries(socket, :artwork_image, fn %{path: temporary_path}, entry ->
        extension = entry.client_name |> Path.extname() |> String.downcase()
        filename = "#{Ecto.UUID.generate()}#{extension}"
        destination = artwork_upload_path(filename)

        File.mkdir_p!(Path.dirname(destination))
        File.cp!(temporary_path, destination)

        {:ok, {"/uploads/artworks/#{filename}", destination}}
      end)

    case uploaded_paths do
      [] -> {params, []}
      [{image_url, path}] -> {Map.put(params, "image_url", image_url), [path]}
    end
  end

  defp artwork_upload_path(filename) do
    Path.join([
      :antiquar |> :code.priv_dir() |> to_string(),
      "static",
      "uploads",
      "artworks",
      filename
    ])
  end

  defp upload_error_message(:too_large), do: "Die Datei ist grosser als 10 MB."
  defp upload_error_message(:not_accepted), do: "Erlaubt sind JPG, PNG und WebP."
  defp upload_error_message(:too_many_files), do: "Es kann nur ein Bild hochgeladen werden."
end
