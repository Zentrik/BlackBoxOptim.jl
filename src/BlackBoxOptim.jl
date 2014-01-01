module BlackBoxOptim

export  Optimizer, PopulationOptimizer, 
        bboptimize, compare_optimizers,

        DiffEvoOpt, de_rand_1_bin, de_rand_1_bin_radiuslimited,

        AdaptConstantsDiffEvoOpt, adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited,

        SeparableNESOpt, separable_nes,
        XNESOpt, xnes,

        # Problems
        Problems, is_fixed_dimensional, is_any_dimensional, 
        is_single_objective_problem, is_multi_objective_problem,
        search_space, eval1, evalall, anydim_problem, as_fixed_dim_problem,
        fitness_is_within_ftol,

        # Archive
        TopListArchive, best_fitness, add_candidate!, best_candidate, 
        last_top_fitness,
        width_of_confidence_interval, fitness_improvement_potential,

        # Search spaces
        SearchSpace, FixedDimensionSearchSpace, ContinuousSearchSpace, 
        RangePerDimSearchSpace, symmetric_search_space,
        numdims, mins, maxs, deltas, ranges, range_for_dim, diameters,
        rand_individual, rand_individuals, isinspace, rand_individuals_lhs,

        hat_compare, is_better, is_worse, same_fitness,
        popsize,
        FloatVectorFitness, float_vector_scheme_min, float_vector_scheme_max,
        FloatVectorPopulation,

        name

abstract Optimizer
abstract Evaluator

function setup(o::Optimizer, evaluator::Evaluator)
  # Do nothing, override if you need to setup prior to the optimization loop
end

function finalize(o::Optimizer, evaluator::Evaluator)
  # Do nothing, override if you need to finalize something after the optimization loop
end

# The standard name function converts the type of the optimizer to a string
# and strips off trailing "Opt".
function name(o::Optimizer)
  s = string(typeof(o))
  if s[end-2:end] == "Opt"
    return s[1:end-3]
  else
    return s
  end
end

module Utils
  include("utilities/latin_hypercube_sampling.jl")
end

include("fitness.jl")
include("population.jl")
include("frequency_adaptation.jl")
include("search_space.jl")
include("archive.jl")

abstract PopulationOptimizer <: Optimizer

population(o::PopulationOptimizer) = o.population # Fallback method if sub-types have not implemented it.

# Our design is inspired by the object-oriented, ask-and-tell "optimizer API 
# format" as proposed in:
#
#  Collette, Y., N. Hansen, G. Pujol, D. Salazar Aponte and 
#  R. Le Riche (2010). On Object-Oriented Programming of Optimizers - 
#  Examples in Scilab. In P. Breitkopf and R. F. Coelho, eds.: 
#  Multidisciplinary Design Optimization in Computational Mechanics, Wiley, 
#  pp. 527-565.
#  https://www.lri.fr/~hansen/collette2010Chap14.pdf
#
# but since Julia is not OO this is more reflected in certain patterns of how
# to specify and call optimizers. The basic ask-and-tell pattern is:
#
#   while !optimizer.stop
#     x = ask(optimizer)
#     y = f(x)
#     optimizer = tell(optimizer, x, y)
#   end
#
# after which the best solutions can be found by:
#
#   yopt, xopt = best(optimizer)
#
# We have extended this paradigm with the use of an archive that saves 
# information on what we have learnt about the search space as well as the
# best solutions found. For most multi-objective optimization problems there
# is no single optimum. Instead there are many pareto optimal solutions.
# An archive collects information about the pareto optimal set or some 
# approximation of it. Different archival strategies can be implemented.

# Different optimization algorithms
include("random_search.jl")
include("differential_evolution.jl")
include("adaptive_differential_evolution.jl")
include("natural_evolution_strategies.jl")

# Problems for testing
include(joinpath("problems", "all_problems.jl"))

# End-user/interface functions
include("bboptimize.jl")

end # module BlackBoxOptim