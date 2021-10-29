#!/usr/bin/env Rscript

# This script has two purposes: Firstly, it reads the output CSV
# for both GA and LP solvers, then merge the datasets into a single
# CSV file. Secondly, it parses the "merged" CSV and produces a
# individual CSV for each configuration and instance size tested.
# The user then can refer to these smaller datasets when selecting
# which instances to test, either from the top hardest to prove
# the optimality, or by randomly selecting a few instances from the
# dataset.
#
# For a detailed text of what are these "hardest instances", please
# c.f. the work "New hard benchmark for flowshop scheduling problems
# minimising makespan" of Vallada, Ruiz, and Framinan (2015).
#
# In short, we consider the gap between the LP and the upper bound
# produced by the genetic algorithm as an indicator of the instance
# hardness. This way, instances with larger gap values tend to be
# more difficult to be solved to the optimality.
#

# Configures the interpreter
require(dplyr)
require(data.table)
require(compiler)
invisible(enableJIT(3))
set.seed(1)

# Functions to convert the instance name to the file path.
name2path <- function(name) {
   nodes <- strsplit(name, "_")[[1]][2]
   return (paste0("new-dataset/instances-", nodes, "/", name, ".txt"))
}
name2path.vec <- Vectorize(name2path)

# Read the data and do a little housekeeping on selected columns
heur <- fread("results-ga.csv") %>% dplyr::select(
   -max.tardiness, 
   -total.tardiness, 
   -travel.time, 
   -time, 
   -resets, 
   -solve.seed
)
lb <- fread("results-lp.csv") %>% dplyr::select(instance,cost)

# Shows some output to the user
cat("Heuristic results contains", nrow(heur), "rows.\n")
cat("LP lower bound results contains", nrow(lb), "rows.\n")
cat("\n")

# Merges the two data sources by the instance name
j1 <- dplyr::inner_join(heur, lb, by="instance", suffix=c(".GA",".LP"))

# Computes the optimality gap using the merged table.
# Also sorts the results in a "organic" way.
results <- j1 %>%
   dplyr::mutate(
      gap = (cost.GA-cost.LP)/cost.GA * 100.0
   ) %>%
   dplyr::arrange(
      conf.id,
      -gap,
      nodes,
      density,
      depot.placement,
      node.placement,
      gen.seed
   )

fwrite(results, "results-merged.csv")
cat("Merged results written to 'results-merged.csv'.\n")

# Selects the top 10 instances with the largest optimality 
# gap across the instances sizes.
hardest <- results %>%
   group_by(nodes, vehi) %>%
   arrange(-gap) %>%
   slice_head(n=10) %>%
   mutate(selection = "hardest")

# Also selects 10 other instances at random.
others <- anti_join(results, hardest, by="instance") %>%
   group_by(nodes, vehi) %>%
   arrange(-gap) %>%
   slice_sample(n=10) %>%
   mutate(selection = "sample")

dataset <- bind_rows(hardest, others)
cat("Rows in the final dataset: ", nrow(dataset), ".\n")
cat("\n")

fwrite(dataset, "dataset.csv")
cat("Dataset exported to 'dataset.csv'.\n")

flist <- function(row, output) {
   fna <- paste0(name2path(row["instance"]))
   cat(fna, file = output, append = T, fill = T)
}

# flist <- function(row, output) {
#    fna <- paste0(name2path(row))
#    cat(fna, file = output, append = T, fill = T)
# }

invisible(apply(dataset, 1, flist, output = "dataset.txt"))
#cat("Length:", length(dataset$instance))
#for (inst in dataset$instance) {
#   path <- paste0(name2path(inst), "\n")
#   cat("Looking for", inst, "got", path)
#   cat(path, file = "dataset.txt", append = T, fill = T)
#}
cat("Path to instances of the dataset exported to 'dataset.txt'.\n")

