defmodule GraphColoring do
  @moduledoc """
  Example: Graph Coloring
"""
  require Logger

  @gc_model "mzn/graph_coloring.mzn"

  def optimal_coloring(dzn_file, opts \\ []) do
    MinizincSolver.solve_sync(@gc_model, dzn_file, Keyword.put_new(opts, :solution_handler, GraphColoring.SyncHandler))
  end

  def show_results(gc_results) do
     color_classes = gc_results[:summary][:last_solution][:data]["vertex_sets"]
     Logger.info "Best coloring found: #{MinizincResults.get_objective(gc_results[:summary][:last_solution])} colors"
     solution_status = gc_results[:summary][:status]
     Logger.info "Optimal? #{if solution_status == :optimal, do: "Yes", else: "No"}"
     Enum.each(Enum.with_index(
          ## Model-specific: there are empty color classes, which will be dropped
          Enum.filter(color_classes, fn c -> MapSet.size(c) > 0 end)),
            fn {class, idx} ->
              Logger.info "Color #{idx + 1} -> vertices: #{Enum.join(class, ", ")}"
            end)
  end

  def do_coloring(dzn_file, opts) when is_binary(dzn_file) do
    optimal_coloring(dzn_file, opts) |> show_results
  end

  def do_coloring({vertices, edges}, opts) when is_integer(vertices) and is_list(edges) do
    optimal_coloring(%{edges: edges, n: vertices, n_edges: length(edges)}, opts) |> show_results
  end

end

defmodule  GraphColoring.SyncHandler do
  require Logger

  use MinizincHandler

  def handle_solution(solution) do
    Logger.info "Found coloring to #{MinizincResults.get_objective(solution)} colors"
    solution
  end

  def handle_summary(summary) do
    summary
  end

end