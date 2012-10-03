function [graph, decomposition] = generateGridGraphRowMajor(m,n)

graph = [];
decomposition = cell(2,1);
e_idx = 0;
for i=1:m
    for j=1:n
        % down
        if (i<m)
            graph = [graph; (i-1)*n+j i*n+j];
            decomposition{1} = [decomposition{1}; e_idx];
            e_idx = e_idx+1;
        end
        % right
        if (j<n)
            graph = [graph; (i-1)*n+j (i-1)*n+j+1];
            decomposition{2} = [decomposition{2}; e_idx];
            e_idx = e_idx+1;
        end
    end
end
