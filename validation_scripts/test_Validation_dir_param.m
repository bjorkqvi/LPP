clear
close all

addpath('../LPP/functions/')

%% Location and deployment settings
loc='Suomenlinna';
yyyy=2020;
run_index='depl_04_01'; % Choose location (folder name)
Fn.wr=sprintf('netcdf/WR_dir_param_30min_%s%.0f.nc',loc,yyyy); 
Fn.lp=sprintf('netcdf/dir_param_30min_not_denoised_%s%.0f_%s.nc',loc,yyyy,run_index); 

wr.time=datetime(ncread(Fn.wr,'time'),'convertfrom','posixtime');
wr.mdir=ncread(Fn.wr,'meandir');
wr.pdir=ncread(Fn.wr,'pdir');
wr.mspr=ncread(Fn.wr,'meanspread');
wr.pspr=ncread(Fn.wr,'pspread');

lp.time=datetime(ncread(Fn.lp,'time'),'convertfrom','posixtime');
lp.mdir=ncread(Fn.lp,'meandir');
lp.pdir=ncread(Fn.lp,'pdir');
lp.mspr=ncread(Fn.lp,'meanspread');
lp.pspr=ncread(Fn.lp,'pspread');

fn=fieldnames(wr);

for n=2:length(fn)
    p=fn{n}
    if ~strcmp('time',p)
        subplot (4,1,n-1)
        plot(wr.time,wr.(p),'k');hold on
        plot(lp.time,lp.(p),'r');
        xlim([lp.time(1) lp.time(end)]);
    
    ylabel(p);
    end
end
return

[~,wr.r,lp.r]=joindate(wr.time,wr.hs,lp.time,lp.hs);
