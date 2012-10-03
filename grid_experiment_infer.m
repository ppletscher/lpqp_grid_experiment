function grid_experiment_infer(run_idx)

run_idx = str2num(run_idx);

% load the options
load(sprintf('local/options_%d.mat', run_idx));
    
if (~isdeployed)
    addpath('matluster');
    addpath('lpqp'); % thats a soft link to the library with the lpqp matlab code
    addpath('mplp'); % thats a soft link to the library witht the mplp code is 
end

% fix seed for reproducability
randn('seed', options.seed);
rand('seed', options.seed);

% size is square
m = options.problemsize;
n = options.problemsize;

% generate the graph
[graph, decomposition] = generateGridGraphRowMajor(m,n);
graph = graph';
num_edges = size(graph, 2);
[D,V] = generate_potentials_ravikumar(m, n, num_edges, options.numstate, options.snr);

if(strcmp(options.algorithm, 'lpqpsdd'))
    options_algo = [];
    options_algo.rho_start = 1e-1;
    options_algo.rho_end = 1e6;
    options_algo.eps_mp = 1e-2;
    options_algo.initial_lp_active = 0;
    options_algo.initial_rho_similar_values = 0;
    
    t_start = tic();
    [mu_unary, history] = mex_lpqp(D, V, graph-1, options_algo, decomposition);
    t_elapsed = toc(t_start)

    mu_rounded = roundSolution(mu_unary);
    ip_obj = computeQPValue(mu_rounded, D, V, graph)
elseif(strcmp(options.algorithm, 'lpqpnpbp'))
    options_algo = [];
    options_algo.rho_start = 1e-1;
    options_algo.initial_lp_active = 0;
    options_algo.initial_rho_similar_values = 0;
    
    t_start = tic();
    [mu_unary, history] = mex_lpqp(D, V, graph-1, options_algo);
    t_elapsed = toc(t_start)

    mu_rounded = roundSolution(mu_unary);
    ip_obj = computeQPValue(mu_rounded, D, V, graph)
    
elseif(strcmp(options.algorithm, 'trws'))
    t_start = tic();
    options_algo = struct([]);
    mu_unary = mex_trws(D, V, graph-1, options_algo);
    t_elapsed = toc(t_start)

    mu_rounded = roundSolution(mu_unary);
    ip_obj = computeQPValue(mu_rounded, D, V, graph)
    history = 0;

elseif(strcmp(options.algorithm, 'mplp'))
    [adj, lambda, local] = convert_lpqp_grid_to_mplp(m, n, D, V, graph);
    
    % run the mplp code from its directory
    output_main_file_name = matluster_generateStringFromOptions(options)
    eval(sprintf('!mkdir %s', output_main_file_name));
    copyfile('./algo_triplet', output_main_file_name);

    params = struct;
    params.file_type = 1; % for grid
    params.base_dir = output_main_file_name;
    
    % ignore the options and use the defaults
    t_start = tic();
    [assign, dual_obj_hist, int_val_hist] = mplp_refine(adj,lambda,local,params);
    t_elapsed = toc(t_start);

    rmdir(output_main_file_name, 's');
    
    mu_unary = assignmentToMarginal(assign, options.numstate);
    ip_obj = computeQPValue(mu_unary, D, V, graph)
    history = 0;

end

result = [];
result.muunary = mu_unary;
result.history = history;
result.ipobj = ip_obj;
result.telapsed = t_elapsed;

% save all the results
if (~exist('output', 'dir'))
    mkdir('output');
end
conf_str = matluster_generateStringFromOptions(options);
filename = sprintf('output/%s.mat', conf_str);
save(filename, 'result');
