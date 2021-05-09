%% LPP_acc_nr2nc.m
% -------------------------------------------------------------------------------------------------------------------------------
% This script reads in NR-files (containing acceleration data) and combines the acceleration to a long single time series
% -------------------------------------------------------------------------------------------------------------------------------
% [Reads]
%	NR-files (original LainePoiss ascii)
% [Writes]
%	Netcdf, e.g. netcdf/AccX_Suomenlinna2020_depl_04_01.nc
% [Pre-processing scripts]
%	None
% [Post-processing scripts]
%	LPP_acc2disp_30min_Suomenlinna.m
% -------------------------------------------------------------------------------------------------------------------------------
% This script is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------------------------------

clear
close all

addpath('../LPP/functions/');

loc='depl_04_01'; % Choose location (folder name)

system(sprintf('ls %s/%s/*NR*.txt > %s/%s/NR.list',loc,run_index,loc,run_index));
filelist.lp=importdata(sprintf('%s/%s/NR.list',loc,run_index));

% Remove boat ride etc.
n0=14;
n1=length(filelist.lp)-184;

%% Define vectors
% Read in first NR just to get the length of the vectors
fn=filelist.lp{n0};
nr=lpp_read_nr(fn,'checkgaps',false);

Acc=NaN*ones((n1-n0+1)*length(nr.data.Time),3);
time=Acc(:,1);
row=1;

%% Loop through NR-files, read them, and add to a single long block
for n=n0:n1
    disp(n)
    fn=filelist.lp{n};
    
    nr=lpp_read_nr(fn,'checkgaps',false);
    drow=length(nr.data.Time);
    time(row:row+drow-1)=nr.data.Time;
    
    Acc(row:row+drow-1,:)=[nr.data.AccX nr.data.AccY nr.data.AccZ];
    row=row+drow;

end

% Starting time of deployment
time0=nr.header.time0;

%% Save data to files
Fn=sprintf('netcdf/AccX_Suomenlinna2020_%s.nc',loc);
lpp_write_netcdf_nrdata(Fn,squeeze(Acc(:,1,:)),time,time0,'name','Suomenlinna','run_index',loc);
Fn=sprintf('netcdf/AccY_Suomenlinna2020_%s.nc',loc);
lpp_write_netcdf_nrdata(Fn,squeeze(Acc(:,2,:)),time,time0,'name','Suomenlinna','run_index',loc);
Fn=sprintf('netcdf/AccZ_Suomenlinna2020_%s.nc',loc);
lpp_write_netcdf_nrdata(Fn,squeeze(Acc(:,3,:)),time,time0,'name','Suomenlinna','run_index',loc);
