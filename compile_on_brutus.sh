mcc -R nodisplay -R nojvm -m grid_experiment_infer.m -a lpqp/ -a mplp/ -a matluster/
sed -i '7i\export MCR_CACHE_ROOT=${TMPDIR};' run_grid_experiment_infer.sh
