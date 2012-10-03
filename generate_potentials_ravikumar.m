function [D,V] = generate_potentials_ravikumar(m, n, num_edges, num_states, SNR)
	
	D = 2*SNR*rand(num_states, m*n) - SNR;
	
	r = 2*rand(1, num_edges)-1;
	V = repmat(reshape(diag(ones(num_states,1)), num_states*num_states, 1), [1 num_edges]) .* repmat(r, [num_states*num_states 1]);
end
