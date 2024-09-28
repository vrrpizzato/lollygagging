defmodule Lollygagging.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :username, :string, default: ""
    field :likes_count, :integer, default: 0
    field :reposts_count, :integer, default: 0
    field :parent_id, :integer

    belongs_to :parent, __MODULE__, foreign_key: :parent_id, references: :id, define_field: false
    has_many :children, __MODULE__, foreign_key: :parent_id, references: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :username, :parent_id])
    |> validate_required([:body])
    |> validate_length(:body, min: 2, max: 256)
  end
end
