defmodule FifoQueue do
  def enqueue(queue \\ [], value) do
    List.insert_at(queue, -1, value)
  end

  def dequeue([]), do: {nil, []}
  def dequeue([head | tail]), do: {head, tail}
end