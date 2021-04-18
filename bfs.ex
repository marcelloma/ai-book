Code.require_file("common/graph.ex")
Code.require_file("common/fifo_queue.ex")
Code.require_file("common/romania.ex")

defmodule BFS.State do
  defstruct graph: Graph.new(),
            goal: :empty,
            reached: Map.new(),
            frontier: Keyword.new(),
            node: nil
end

defmodule BFS.Node do
  defstruct label: :empty,
            parent: nil,
            total_cost: 0

  def new({label, cost}, parent) do
    %__MODULE__{
      label: label,
      total_cost: parent.total_cost + cost,
      parent: parent
    }
  end

  def print(node, str \\ "")
  def print(node, str) when is_nil(node.parent), do: to_string(node.label) <> str
  def print(node, str), do: print(node.parent, " => " <> to_string(node.label) <> str)
end

defmodule BFS do
  alias BFS.State
  alias BFS.Node

  def search(graph, current, goal) do
    node = %Node{label: current}
    frontier = expand(graph, node)

    %State{graph: graph, node: node, goal: goal, frontier: frontier}
    |> search
  end

  def search(state) when state.node.label == state.goal, do: {:success, state.node}
  def search(state) when length(state.frontier) == 0, do: {:failure}

  def search(state) do
    {node, new_frontier} = FifoQueue.dequeue(state.frontier)

    reached = Map.get(state.reached, node.label)

    if is_nil(reached) do
      reached = Map.put(state.reached, node.label, node)
      children = expand(state.graph, node)

      Enum.reduce_while(children, new_frontier, fn x, acc ->
        if x.label == state.goal,
          do: {:halt, {:goal_reached, x}},
          else: {:cont, FifoQueue.enqueue(acc, x)}
      end)
      |> case do
        {:goal_reached, node} ->
          {:success, node}

        new_frontier ->
          search(%State{state | node: node, reached: reached, frontier: new_frontier})
      end
    else
      search(%State{state | node: node, frontier: new_frontier})
    end
  end

  defp expand(graph, node) do
    Graph.get_adjacency(graph, node.label)
    |> Enum.map(&Node.new(&1, node))
  end
end

defmodule Main do
  def run do
    graph = Romania.graph()

    case BFS.search(graph, :Arad, :Bucharest) do
      {:success, node} ->
        IO.puts(node.total_cost)
        BFS.Node.print(node) |> IO.puts()

      {:failure} ->
        IO.puts("Failed")
    end
  end
end

Main.run()