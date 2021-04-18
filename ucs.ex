Code.require_file("common/graph.ex")
Code.require_file("common/priority_queue.ex")
Code.require_file("common/search_node.ex")
Code.require_file("common/romania.ex")

defmodule UCS.State do
  defstruct graph: Graph.new(),
            goal: :empty,
            reached: %{},
            frontier: [],
            node: nil

  def new(graph, current, goal) do
    node = %SearchNode{label: current}
    reached = Map.put(%{}, current, node)
    %__MODULE__{graph: graph, node: node, reached: reached, goal: goal}
  end
end

defmodule UCS do
  def search(state) when length(state.frontier) == 0, do: {:failure}

  def search(state) do
    state = pop state

    IO.inspect(%{path: SearchNode.print(state.node)})

    cond do
      state.node.label == state.goal ->
        {:success, state}
      true ->
        state
        |> expand
        |> search
    end
  end

  def expand(state) do
    frontier =
      Graph.get_adjacency(state.graph, state.node.label)
      |> Enum.map(&(SearchNode.new(&1, state.node) |> node_priority))
      |> Enum.filter(&is_reached(state, &1))
      |> Enum.reduce(state.frontier, &PriorityQueue.enqueue(&2, &1))

    state
    |> Map.put(:frontier, frontier)
  end

  defp pop(state) do
    {{node, _}, frontier} = PriorityQueue.dequeue(state.frontier)

    state
    |> Map.put(:node, node)
    |> Map.put(:frontier, frontier)
    |> reach_node
  end

  defp reach_node(state) do
    reached =
      state.reached
      |> Map.put(state.node.label, state.node)

    state
    |> Map.put(:reached, reached)
  end

  defp is_reached(state, {node, _}) do
    reached = Map.get(state.reached, node.label)
    is_nil(reached) or node.total_cost < reached.total_cost
  end

  defp node_priority(node), do: {node, node.total_cost}
end

defmodule Main do
  def run do
    graph = Romania.graph()

    result =
      UCS.State.new(graph, :Arad, :Bucharest)
      |> UCS.expand()
      |> UCS.search()

    case result do
      {:success, state} ->
        IO.puts("")
        IO.inspect(%{totalCost: state.node.total_cost, solution: SearchNode.print(state.node)})

      {:failure, _} ->
        IO.puts("")
        IO.puts("Failure")
    end
  end
end

Main.run()