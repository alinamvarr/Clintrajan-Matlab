function ProjStruct = project_on_tree_from_python(X, tree_elpi)
    % Create Python script for projection
    python_script = sprintf(['import numpy as np\n',...
        'import elpigraph\n',...
        'from elpigraph.src.core import PartitionData\n',...
        'from elpigraph.src.reporting import project_point_onto_graph\n',...
        'from scipy.io import savemat, loadmat\n\n',...
        'def project_on_tree(X, tree):\n',...
        '    # Extract node positions and edges\n',...
        '    nodep = tree["NodePositions"]\n',...
        '    edges = tree["Edges"]\n',...
        '    \n',...
        '    # Calculate partition using ElPiGraph core function\n',...
        '    squared_X = np.sum(X**2, axis=1, keepdims=1)\n',...
        '    partition, dists = PartitionData(\n',...
        '        X=X,\n',...
        '        NodePositions=nodep,\n',...
        '        MaxBlockSize=100000000,\n',...
        '        TrimmingRadius=float("inf"),\n',...
        '        SquaredX=squared_X\n',...
        '    )\n',...
        '    \n',...
        '    # Project points onto graph\n',...
        '    ProjStruct = project_point_onto_graph(\n',...
        '        X=X,\n',...
        '        NodePositions=nodep,\n',...
        '        Edges=edges,\n',...
        '        Partition=partition\n',...
        '    )\n',...
        '    \n',...
        '    # Add necessary information to projection structure\n',...
        '    ProjStruct["Partition"] = partition\n',...
        '    ProjStruct["NodePositions"] = nodep\n',...
        '    ProjStruct["dists"] = dists\n',...
        '    \n',...
        '    # Print some information\n',...
        '    print(f"Processed {X.shape[0]} points")\n',...
        '    print(f"Tree has {nodep.shape[0]} nodes and {len(edges)} edges")\n',...
        '    \n',...
        '    return ProjStruct\n',...
        '\n',...
        'def compute_projection(input_file, output_file):\n',...
        '    # Load data\n',...
        '    data = loadmat(input_file)\n',...
        '    X = data["X"]\n',...
        '    \n',...
        '    # Construct tree dictionary\n',...
        '    tree = {\n',...
        '        "NodePositions": data["NodePositions"],\n',...
        '        "Edges": data["Edges"]\n',...
        '    }\n',...
        '    \n',...
        '    # Compute projections\n',...
        '    proj = project_on_tree(X, tree)\n',...
        '    \n',...
        '    # Save results\n',...
        '    savemat(output_file, proj)\n',...
        '\n',...
        'if __name__ == "__main__":\n',...
        '    import sys\n',...
        '    compute_projection(sys.argv[1], sys.argv[2])\n']);

    % Save Python script
    script_file = 'temp_project.py';
    fid = fopen(script_file, 'w');
    fprintf(fid, '%s', python_script);
    fclose(fid);
    
    % Prepare input data
    input_file = 'temp_proj_input.mat';
    output_file = 'temp_proj_output.mat';
    
    % Handle Edges format from tree_elpi
    if iscell(tree_elpi.Edges)
        Edges = tree_elpi.Edges{1};
    else
        Edges = tree_elpi.Edges;
    end
    NodePositions = tree_elpi.NodePositions;
    
    % Save input data
    save(input_file, 'X', 'NodePositions', 'Edges');
    
    % Run Python script
    command = sprintf('/opt/anaconda3/bin/python %s %s %s', script_file, input_file, output_file);
    [status, cmdout] = system(command);
    
    if status ~= 0
        fprintf('Error output from Python:\n%s\n', cmdout);
        error('Python script failed to execute properly');
    else
        fprintf('%s', cmdout);  % Display Python output
    end
    
    % Load results and validate
    ProjStruct = load(output_file);
    
    % Verify required fields are present
    required_fields = {'ProjectionValues', 'EdgeID', 'Edges', 'Partition', 'NodePositions', 'dists'};
    for i = 1:length(required_fields)
        if ~isfield(ProjStruct, required_fields{i})
            error('Missing required field in projection results: %s', required_fields{i});
        end
    end
    
    % Display summary information
    fprintf('\nProjection Results Summary:\n');
    fprintf('------------------------\n');
    fprintf('Number of points processed: %d\n', size(X, 1));
    fprintf('Number of nodes in tree: %d\n', size(NodePositions, 1));
    fprintf('Number of edges in tree: %d\n', size(Edges, 1));
    
    % Clean up temporary files
    delete(input_file);
    delete(output_file);
    delete(script_file);
end
