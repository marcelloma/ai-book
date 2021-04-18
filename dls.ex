Code.require_file("graph.ex")

defmodule DLS.Node do
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

defmodule DLS.State do
  defstruct [
    graph: Graph.new,
    initial: :empty,
    goal: :empty,
    node: nil,
    limit: 0,
  ]

  def new(graph, current, goal, limit) do
    %__MODULE__{
      graph: graph,
      goal: goal,
      initial: current,
      node: %DLS.Node{label: current},
      limit: limit
    }
  end
end

defmodule DLS do
  alias DLS.State
  alias DLS.Node

  def search(state, depth \\ 0)
  
  def search(state, depth) when depth >= state.limit do
    IO.inspect %{depth: depth, path: Node.print(state.node)}

    {:failure, %State{state|node: state.node.parent}}
  end

  def search(state, depth) when state.node.label == state.goal do
    IO.inspect %{depth: depth, path: Node.print(state.node)}

    {:success, state}
  end
  
  def search(state, depth) do
    %{node: node} = state
    children = expand(state.graph, node)

    new_graph = state.graph |>
      Graph.set_vertex_data(node.label, %{visited: true})

    state = %State{state | graph: new_graph}

    IO.inspect %{depth: depth, path: DLS.Node.print(node)}
    
    Enum.reduce_while(children, {:empty, state}, fn child, acc ->
      {_, state_acc} = acc
      case Graph.get_vertex_data(state_acc.graph, child.label) do
        %{visited: true} -> {:cont, {:failure, state}}
        _ ->
          case search(%State{state_acc | node: child}, depth + 1) do
            {:success, state} -> {:halt, {:success, state}}
            {:failure, state} -> {:cont, {:failure, state}} 
          end
      end
    end)    
  end

  defp expand(graph, node) do
    Graph.get_adjacency(graph, node.label)
    |> Enum.map(& Node.new(&1, node))
  end
end

defmodule IDS do
  alias DLS
  alias DLS.State

  def search(state, cutoff) when state.limit == cutoff, do: {:failure, state}
  def search(state, cutoff) do
    limit = state.limit + 1
    new_state = State.new(state.graph, state.initial, state.goal, limit)
    
    IO.puts ""
    IO.puts "DLS on limit " <> to_string(limit)

    case DLS.search(new_state) do
      {:success, state} -> {:success, state}
      {:failure, _} -> search(new_state, cutoff)
    end
  end
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

    state = 
      DLS.State.new(graph, :Arad, :Bucharest, 0)

    case IDS.search(state, 4) do
      {:success, state} ->
        IO.puts ""
        IO.inspect %{totalCost: state.node.total_cost, solution: DLS.Node.print(state.node)}
      {:failure, _} ->
        IO.puts ""
        IO.puts "Failure"
    end
  end
end

Main.run