% for size 120 even sweeter!

filename_prefix = 'output/seed=1_size=90_numstates=2_snr=0.050000_algo=';

load([filename_prefix 'trws.mat']);
obj_trws = ip_obj;

load([filename_prefix 'mplp.mat']);
obj_mplp = ip_obj;

load([filename_prefix 'lpqpnpbp.mat']);

obj = struct();
obj(1).name = 'trws';
obj(1).value = obj_trws;
obj(1).color = 'orange';
obj(2).name = 'mplp';
obj(2).value = obj_mplp;
obj(2).color = 'cyan';

visualizeHistory(history, obj)

outputHistoryToFile(history, 'grid', obj);
