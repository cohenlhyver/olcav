
load samples_lfp; signal=samples;
load tstamps_lfp; tstim=time_stamps-time_stamps(1); %Size 322
load num_stim;
%load tstamps2_lfp; timestamps; %size 12511

rate=30303;

n_repet=20;
n_stim=8;
stim_start=3;

avant=round(0.1*rate);; %temps a garder avant en nb de frame (soit 100 ms=0.1s)
apres=round(0.7*rate); %temps a garder apres en nb de frame (soit 600 ms=0.6s)

tmp=zeros(24243,n_stim,n_repet);
%tmp=zeros(24243,n_stim*n_repet);
idx_cond=1;
for repet=1:n_repet
    for stim=1:n_stim
        cond=(repet-1)*n_stim*2+(stim-1)*2+stim_start;
        frame_ref=round(tstim(cond)/1e6*rate);        
        frame_avant=frame_ref-avant;
        frame_apres=frame_ref+apres;
        tmp(:,flags.index(idx_cond),repet)=signal(frame_avant:frame_apres)-signal(frame_ref);
        idx_cond=idx_cond+1;
    end
end

subplot(1,2,1); plot(mean(tmp,3))
subplot(1,2,2); plot(mean(tmp(:,:),2))