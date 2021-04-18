Code.require_file("common/graph.ex")
Code.require_file("common/priority_queue.ex")
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
    {{node, _}, new_frontier} = PriorityQueue.dequeue(state.frontier)

    reached = Map.get(state.reached, node.label)

    cond do
      is_nil(reached) or node.total_cost < reached.total_cost ->
        reached = Map.put(state.reached, node.label, node)

        search(%State{
          state
          | node: node,
            reached: reached,
            frontier: expand(state.graph, node, new_frontier)
        })

      true ->
        search(%State{state | node: node, frontier: new_frontier})
    end
  end

  defp expand(graph, node, frontier \\ []) do
    Graph.get_adjacency(graph, node.label)
    |> Enum.map(&(Node.new(&1, node) |> node_priority))
    |> Enum.reduce(frontier, &PriorityQueue.enqueue(&2, &1))
  end

  defp node_priority(node), do: {node, node.total_cost}
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