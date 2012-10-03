function [adj, lambda, local] = convert_lpqp_grid_to_mplp(m, n, D, V, graph)
	
	%negate the potentials
	D = -1*D;
	V = -1*V;

	num_states = size(D,1);	
	num_edges = size(graph,2);
	num_variables = m*n;
	
	%create the adjacency matrix
	adj = sparse(num_variables, num_variables);
	%This is the pairwise potentials	
    lambda = cell(num_variables, num_variables);
	% Now unaries
	local = cell(1,num_variables);

	for eidx=1:num_edges
		% fill the adjacency
		adj(graph(1,eidx),graph(2,eidx)) = 1;
		adj(graph(2,eidx),graph(1,eidx)) = 1;
		% The pairwise potentials
		curr_potentials_mat = reshape(V(:,eidx),num_states, num_states);
		lambda{graph(1,eidx),graph(2,eidx)} = curr_potentials_mat;
		lambda{graph(2,eidx),graph(1,eidx)} = curr_potentials_mat';
	end
	for vidx=1:num_variables
		local{vidx} = D(:,vidx);
	end
	
end
