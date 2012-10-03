function prepare()

addpath('matluster');

run_idx = 0;

% initialization
if (~exist('local', 'dir'))
    mkdir('local');
end
fid = fopen('grid_experiment.sh', 'w');

% formatting
format = [];
format.problemsize = '%d';
format.snr = '%f';
format.numstate = '%d';
format.seed = '%d';
format.algorithm = '%s';

% reporting
reporting = [];
reporting.groupby = {};

% init options
options = [];
options.format = format;
options.reporting = reporting;

% grid search
problemsizes = [60, 90, 120];
snrs = [0.05, 0.5];
numstates = [2, 5];
seeds = [1:5]; 
algorithms = {'mplp','lpqpnpbp', 'lpqpsdd','trws'};

for problemsize=problemsizes
    options.problemsize = problemsize;

    for snr=snrs
        options.snr = snr;

        for numstate=numstates
            options.numstate = numstate;
        
            for seed=seeds
                options.seed = seed;
    
                for algorithm_idx=1:numel(algorithms)
                    options.algorithm = algorithms{algorithm_idx};

                    filename = sprintf('local/options_%d.mat', run_idx);
                    save(filename, 'options');

                    timelimit = '08:00';
                    matluster_addJobToQueue(fid, options, run_idx, './run_grid_experiment_infer.sh /cluster/apps/matlab/7.14/', timelimit);
                    
                    run_idx = run_idx+1;
                end
            end
        end
    end
end

num_runs = run_idx;
save('local/num_runs.mat', 'num_runs');

fclose(fid);
unix('chmod +x grid_experiment.sh');
