defmodule Lollygagging.Repo.Migrations.AddParentIdToPosts do
  use Ecto.Migration

  def up do
    alter table(:posts) do
      add :parent_id, :integer
    end
  end

  def down do
    alter table(:posts) do
      remove :parent_id
    end
  end
end
