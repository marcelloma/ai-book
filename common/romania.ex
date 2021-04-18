Code.require_file("common/graph.ex")

defmodule Romania do
  def graph do
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
      Graph.Edge.new(:Hirsova, :Eforie, 86)
    ]

    Enum.reduce(edges, Graph.new(), &Graph.add_edge(&2, &1))
  end
end