defmodule Graph.Edge do
  defstruct vertex_v: :empty,
            vertex_u: :empty,
            weight: 0

  def new(vertex_v, vertex_u, weight) do
    %__MODULE__{
      vertex_v: vertex_v,
      vertex_u: vertex_u,
      weight: weight
    }
  end
end

defmodule Graph do
  defstruct adjacency_list: %{},
            vertexes: %{},
            type: :undirected

  def new() do
    %__MODULE__{}
  end

  def add_edge(%__MODULE__{} = graph, %Graph.Edge{} = edge) do
    %{vertexes: vtx_list, adjacency_list: adj_list} = graph
    %{vertex_u: u, vertex_v: v, weight: w} = edge

    adj_u =
      Map.get(adj_list, u, [])
      |> Keyword.put(v, w)

    adj_v =
      Map.get(adj_list, v, [])
      |> Keyword.put(u, w)

    new_adj_list =
      adj_list
      |> Map.put(v, adj_v)
      |> Map.put(u, adj_u)

    new_vtx_list =
      vtx_list
      |> Map.put_new(u, %{})
      |> Map.put_new(v, %{})

    graph
    |> Map.put(:adjacency_list, new_adj_list)
    |> Map.put(:vertexes, new_vtx_list)
  end

  def get_adjacency(%__MODULE__{} = graph, vertex) do
    Map.get(graph.adjacency_list, vertex, [])
  end

  def get_vertex_data(%__MODULE__{} = graph, vertex) do
    Map.get(graph.vertexes, vertex, %{})
  end

  def set_vertex_data(%__MODULE__{} = graph, vertex, vertex_data) do
    new_vertexes =
      graph.vertexes
      |> Map.put(vertex, vertex_data)

    graph
    |> Map.put(:vertexes, new_vertexes)
  end
end