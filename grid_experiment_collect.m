function collect()

addpath('matluster');

load('local/num_runs.mat');

collection = matluster_collect(num_runs);

tab_obj = matluster_reshapeResults(collection{1}, 'ipobj');
tab_time = matluster_reshapeResults(collection{1}, 'telapsed');

assert(isequal(tab_obj.param_name{1},'problemsize'));
assert(isequal(tab_obj.param_name{2},'snr'));
assert(isequal(tab_obj.param_name{3},'numstate'));
assert(isequal(tab_obj.param_name{4},'seed'));
assert(isequal(tab_obj.param_name{5},'algorithm'));

for problemsize_idx=1:numel(tab_obj.param_values{1})
    for snr_idx=1:numel(tab_obj.param_values{2})
        for numstate_idx=1:numel(tab_obj.param_values{3})
            scores = squeeze(tab_obj.results(problemsize_idx, snr_idx, numstate_idx,:,:));
            time = squeeze(tab_time.results(problemsize_idx, snr_idx, numstate_idx,:,:));

            % scoring of the energies
            maxs = max(scores,[],2);
            mins = min(scores,[],2);
            scores = (repmat(maxs, [1 size(scores,2)]) - scores)./max(repmat(maxs - mins, [1 size(scores,2)]), 1e-15);
            fprintf('configuration: problemsize: %d, snr: %f, numstate: %d.\n', ...
                    tab_obj.param_values{1}(problemsize_idx), ...
                    tab_obj.param_values{2}(snr_idx), ...
                    tab_obj.param_values{3}(numstate_idx));
            tab_obj.param_values{5}
            m = mean(scores,1)
            s = std(scores,[],1)

            % timing results
            assert(isequal(tab_obj.param_values{5}{1}, 'lpqpnpbp'));
            assert(isequal(tab_obj.param_values{5}{2}, 'lpqpsdd'));
            assert(isequal(tab_obj.param_values{5}{3}, 'mplp'));
            speedup = mean(time(:,3)./time(:,1));
            fprintf('mean speedup lpqpnpbp over mplp: %f.\n',speedup)
            speedup = mean(time(:,3)./time(:,2));
            fprintf('mean speedup lpqpnpbp over mplp: %f.\n',speedup)
        end
    end
end
