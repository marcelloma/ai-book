defmodule PriorityQueue do
  def enqueue([], {val, pri}), do: [{val, pri}]

  def enqueue(queue, {val, pri}) do
    Enum.find_index(queue, fn {_, xpri} -> xpri > pri end)
    |> case do
      nil -> List.insert_at(queue, -1, {val, pri})
      pos -> List.insert_at(queue, pos, {val, pri})
    end
  end

  def dequeue([]), do: {nil, []}
  def dequeue([head | tail]), do: {head, tail}
end