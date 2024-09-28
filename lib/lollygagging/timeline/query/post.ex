defmodule Lollygagging.Timeline.Query.Post do
  import Ecto.Query, warn: false

  def posts_by_criteria(criteria) do
    Enum.reduce(criteria, dynamic(true), fn
      {:order, _value}, dynamic ->
        dynamic

      {field, nil}, dynamic ->
        filter(dynamic, field, :is, nil)

      {field, value}, dynamic ->
        filter(dynamic, field, :eq, value)

      _, _ ->
        dynamic(false)
    end)
  end

  def filter(dynamic, field, :is, nil) do
    dynamic([p], ^dynamic and is_nil(field(p, ^field)))
  end

  def filter(dynamic, field, :eq, value) do
    dynamic([p], ^dynamic and field(p, ^field) == ^value)
  end
end
