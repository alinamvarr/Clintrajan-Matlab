# Clintrajan-Matlab
This repository demonstrates how to integrate the ClinTrajan (ElPiGraph-based) Python pipeline within MATLAB. The MATLAB code automatically writes temporary Python scripts, calls them via the system shell, and then reads back the results.


## Contents

1. **`compute_tree_from_python.m`**  
   Builds an elastic principal tree from data `X` using ElPiGraph in Python.

2. **`partition_data_from_python.m`**  
   Partitions data points among the branches of the tree.

3. **`extract_trajectories_from_python.m`**  
   Extracts shortest-path trajectories (0-based) from a given root node to each leaf.

4. **`project_on_tree_from_python.m`**  
   Projects each data point onto the tree edges, returning `ProjStruct` with distances and edge IDs.

5. **`quantify_pseudotime_from_python.m`**  
   Computes pseudotime for each point along each trajectory, assuming **0-based** indexing.



## Usage

A typical workflow in MATLAB:

```matlab
% 1) Build the tree
tree_elpi = compute_tree_from_python(X, 'nnodes', 50);

% 2) Partition data by branch
[branches, partition] = partition_data_from_python(X, tree_elpi);

% 3) Extract 0-based trajectories from a chosen 0-based root
root_node = 0;  % e.g., node #0
[all_traj, all_traj_edges] = extract_trajectories_from_python(tree_elpi, root_node);

% 4) Project data points onto the tree
ProjStruct = project_on_tree_from_python(X, tree_elpi);

% 5) Quantify pseudotime (still 0-based)
PseudoTimeTraj = quantify_pseudotime_from_python(all_traj, all_traj_edges, ProjStruct);

% 6) Build a table of point->branch->pseudotime, etc.
T = save_point_projections_in_table_0based(branches, PseudoTimeTraj, 'results.txt');
,,,

### Notes
All edges, node IDs, and trajectories are 0-based in this pipeline.
If you prefer 1-based indexing in MATLAB for convenience, you can add or subtract 1 in each step—but ensure consistency everywhere.

### Windows users
On Windows, you may need to specify the path to your Python interpreter differently, for example:

```matlab
command = sprintf('"%s" %s %s %s', ...
    'C:\\Users\\YourName\\anaconda3\\python.exe', script_file, input_file, output_file);
[status, cmdout] = system(command);
,,,
