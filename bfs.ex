Code.require_file("common/graph.ex")
Code.require_file("common/fifo_queue.ex")
Code.require_file("common/search_node.ex")
Code.require_file("common/romania.ex")

defmodule BFS.State do
  defstruct graph: Graph.new(),
            goal: :empty,
            reached: Map.new(),
            frontier: Keyword.new(),
            node: nil
end

defmodule BFS do
  alias BFS.State

  def search(graph, current, goal) do
    node = %SearchNode{label: current}
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
    |> Enum.map(&SearchNode.new(&1, node))
  end
end

defmodule Main do
  def run do
    graph = Romania.graph()

    case BFS.search(graph, :Arad, :Bucharest) do
      {:success, node} ->
        IO.puts(node.total_cost)
        SearchNode.print(node) |> IO.puts()

      {:failure} ->
        IO.puts("Failed")
    end
  end
end

Main.run()