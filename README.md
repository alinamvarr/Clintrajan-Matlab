# Clintrajan-Matlab
This repository demonstrates how to integrate the ClinTrajan (ElPiGraph-based) Python pipeline within MATLAB. The MATLAB code automatically writes temporary Python scripts, calls them via the system shell, and then reads back the results.


# README

This repository contains MATLAB functions that call Python scripts to perform Elastic Principal Graph computations and other downstream analyses. The main files include:

1. **`compute_tree_from_python.m`**  
2. **`extract_trajectories_from_python.m`**  
3. **`partition_data_from_python.m`**  
4. **`project_on_tree_from_python.m`**  
5. **`quantify_pseudotime_from_python.m`**

Each file creates a temporary Python script and then **calls Python** via a `system()` command.

---

## Requirements

- **MATLAB** R2019a or newer (earlier versions might require different syntax).
- **Python** 3.x installation (Anaconda/Miniconda recommended).
- **ElPiGraph** library installed (e.g., `pip install elpigraph`).
- **igraph** Python package installed (e.g., `pip install igraph`).
- Additional Python dependencies: `numpy`, `scipy`, `pandas`, etc. as required.

---

## Setup
### 1. Update the MATLAB `command` lines for Python calls

Each `.m` file has a line like:
```matlab
command = sprintf('/opt/anaconda3/bin/python %s %s %s', script_file, input_file, output_file);
```
For **Windows users**, you should edit these lines to reflect your Anaconda (or Miniconda) path. For example:
% Example change on Windows:
```matlab
command = sprintf('"%s" "%s" "%s" "%s"', ...
    'C:\Users\YourName\anaconda\python.exe', script_file, input_file, output_file);
[status, commandOutput] = system(command);
```

## Usage Example
In MATLAB:
```matlab
% Suppose X is your data matrix (e.g., 1000 x 2):
X = randn(1000, 2);

% 1) Compute an elastic principal tree:
tree_elpi = compute_tree_from_python(X, ...
    'nnodes', 50, ...
    'alpha', 0.01, ...
    'Mu', 0.1, ...
    'Lambda', 0.05, ...
    'FinalEnergy', 'Penalized', ...
    'Do_PCA', true);

% 2) Partition data by branches
[vec_labels_by_branches, partition_by_node] = partition_data_from_python(X, tree_elpi);

% 3) Extract trajectories (root_node is 0-based)
root_node = 8;
[all_trajectories, all_trajectories_edges] = extract_trajectories_from_python(tree_elpi, root_node);

% 4) Project data onto the tree
ProjStruct = project_on_tree_from_python(X, tree_elpi);

% 5) Quantify pseudotime along each trajectory
PseudoTimeTraj = quantify_pseudotime_from_python(all_trajectories, all_trajectories_edges, ProjStruct);

% Now you can explore PseudoTimeTraj, partition results, etc.
```

## Common Issues
**Path Not Found**: If you see an error like 'python' is not recognized on Windows, then ensure:

You replaced the default path with "C:\\Users\\<YourName>\\anaconda3\\python.exe" (escaped backslashes).
Or that your path to python is on the system PATH.

**Missing Python Packages**:
Install required packages with pip install elpigraph numpy scipy pandas igraph (or use conda install equivalents if you prefer conda).

**Permission Errors**:
Make sure the folder containing your .m scripts is writable, so the temporary .py files can be created.


## Acknowledgments

- [ClinTrajan GitHub Repository](https://github.com/auranic/ClinTrajan)

