defmodule Edge do
  defstruct [
    vertex_v: :empty,
    vertex_u: :empty,
    weight: 0,
  ]

  def new(vertex_v, vertex_u, weight) do
    %__MODULE__{
      vertex_v: vertex_v,
      vertex_u: vertex_u,
      weight: weight
    }
  end
end

defmodule Graph do
  defstruct [
    adjacency_list: Map.new,
    vertexes: Map.new,
    type: :undirected,
  ]

  def new() do
    %__MODULE__{}
  end

  def add_edge(graph, %Edge{vertex_u: vertex_u, vertex_v: vertex_v, weight: weight}) do
    adjacency_u =
      Map.get(graph.adjacency_list, vertex_u, [])
      |> Keyword.put(vertex_v, weight)

    adjacency_v =
      Map.get(graph.adjacency_list, vertex_v, Keyword.new)
      |> Keyword.put(vertex_u, weight)
    
    new_adjacency_list =
      graph.adjacency_list
      |> Map.put(vertex_v, adjacency_v)
      |> Map.put(vertex_u, adjacency_u)
    
    new_vertexes =
      graph.vertexes
      |> Map.put_new(vertex_u, Map.new)
      |> Map.put_new(vertex_v, Map.new)

    %{graph | adjacency_list: new_adjacency_list, vertexes: new_vertexes}
  end

  def get_adjacency(graph, vertex) do
    Map.get(graph.adjacency_list, vertex, Keyword.new)
  end

  def get_vertex_data(graph, vertex) do
    Map.get(graph.vertexes, vertex, Map.new)
  end
  
  def set_vertex_data(graph, vertex, vertex_data) do
    new_vertexes =
      graph.vertexes
      |> Map.put(vertex, vertex_data)

    %{graph | vertexes: new_vertexes}
  end
end

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
      Edge.new(:Arad, :Zerind, 75),
      Edge.new(:Arad, :Timisoara, 118),
      Edge.new(:Arad, :Sibiu, 140),
      Edge.new(:Zerind, :Oradea, 71),
      Edge.new(:Oradea, :Sibiu, 151),
      Edge.new(:Timisoara, :Lugoj, 111),
      Edge.new(:Lugoj, :Mehadia, 70),
      Edge.new(:Mehadia, :Drobeta, 75),
      Edge.new(:Drobeta, :Craiova, 120),
      Edge.new(:Craiova, :Rimnicu_Vilcea, 146),
      Edge.new(:Craiova, :Pitesti, 138),
      Edge.new(:Sibiu, :Fagaras, 99),
      Edge.new(:Sibiu, :Rimnicu_Vilcea, 80),
      Edge.new(:Rimnicu_Vilcea, :Pitesti, 97),
      Edge.new(:Fagaras, :Bucharest, 211),
      Edge.new(:Pitesti, :Bucharest, 101),
      Edge.new(:Bucharest, :Urziceni, 85),
      Edge.new(:Bucharest, :Giurgiu, 90),
      Edge.new(:Urziceni, :Vaslui, 142),
      Edge.new(:Vaslui, :Iasi, 92),
      Edge.new(:Iasi, :Neamt, 87),
      Edge.new(:Urziceni, :Hirsova, 98),
      Edge.new(:Hirsova, :Eforie, 86),
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