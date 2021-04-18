Code.require_file("graph.ex")

defmodule BFS.State do
  defstruct [
    graph: Graph.new,
    goal: :empty,
    reached: Map.new,
    frontier: Keyword.new,
    node: nil,
  ]
end

defmodule BFS.Node do
  defstruct [
    label: :empty,
    parent: nil,
    total_cost: 0,
  ]

  def new({label,cost}, parent) do
    %__MODULE__{
      label: label,
      total_cost: parent.total_cost + cost,
      parent: parent,
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

  def search(state) when state.node.label == state.goal, do: {:success,state.node}
  def search(state) when length(state.frontier) == 0, do: {:failure}
  def search(state) do
    {node,new_frontier} = fifo_dequeue(state.frontier)
    
    reached = Map.get(state.reached, node.label)
    if is_nil(reached) do
      reached = Map.put(state.reached, node.label, node)
      children = expand(state.graph, node)
      Enum.reduce_while(children, new_frontier, fn x, acc ->
        if x.label == state.goal,
          do: {:halt, {:goal_reached, x}},
          else: {:cont, fifo_queue(acc, x)}
      end)
      |> case do
        {:goal_reached, node} -> {:success, node}
        new_frontier -> 
          search %State{state|node: node, reached: reached, frontier: new_frontier }       
      end
    else
      search %State{state|node: node, frontier: new_frontier}   
    end
  end

  defp expand(graph, node) do
    Graph.get_adjacency(graph, node.label)
    |> Enum.map(& Node.new(&1, node))
  end

  def fifo_queue(queue \\ [],  value) do
    List.insert_at(queue, -1, value)
  end

  def fifo_dequeue([]), do: {nil,[]}
  def fifo_dequeue([head|tail]), do: {head,tail}
end

defmodule Main do
  def run do
    edges = [
      Graph.Edge.new(:Arad, :Zerind, 75),
      Graph.Edge.new(:Arad, :Timisoara, 118),
      Graph.Edge.new(:Arad, :Sibiu, 140),
      Graph.Edge.new(:Zerind, :Oradea, 71),
      Graph.Edge.new(:Oradea, :Sibiu, 151),
      Graph.Edge.new(:Timisoara, :Lugoj, 111),
      Graph.Edge.new(:Lugoj, :Mehadia, 70),
      Graph.Edge.new(:Mehadia, :Drobeta, 75),
      Graph.Edge.new(:Drobeta, :Craiova, 120),
      Graph.Edge.new(:Craiova, :Rimnicu_Vilcea, 146),
      Graph.Edge.new(:Craiova, :Pitesti, 138),
      Graph.Edge.new(:Sibiu, :Fagaras, 99),
      Graph.Edge.new(:Sibiu, :Rimnicu_Vilcea, 80),
      Graph.Edge.new(:Rimnicu_Vilcea, :Pitesti, 97),
      Graph.Edge.new(:Fagaras, :Bucharest, 211),
      Graph.Edge.new(:Pitesti, :Bucharest, 101),
      Graph.Edge.new(:Bucharest, :Urziceni, 85),
      Graph.Edge.new(:Bucharest, :Giurgiu, 90),
      Graph.Edge.new(:Urziceni, :Vaslui, 142),
      Graph.Edge.new(:Vaslui, :Iasi, 92),
      Graph.Edge.new(:Iasi, :Neamt, 87),
      Graph.Edge.new(:Urziceni, :Hirsova, 98),
      Graph.Edge.new(:Hirsova, :Eforie, 86),
    ]

    graph =
      Enum.reduce(edges, Graph.new, & Graph.add_edge(&2, &1))
      |> IO.inspect

    case BFS.search(graph, :Arad, :Bucharest) do
      {:success, node} ->
        IO.puts node.total_cost
        BFS.Node.print(node) |> IO.puts
      {:failure} ->
        IO.puts "Failed"
    end
  end
end

Main.run

