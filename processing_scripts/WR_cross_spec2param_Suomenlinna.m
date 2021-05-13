clear
close all

addpath('../LPP/functions/')

%% Location and deployment settings
loc='Suomenlinna';
yyyy=2020;
Fn=sprintf('netcdf/WR_cross_spec_30min_%s%.0f.nc',loc,yyyy); 

%% Get times and raw data blocks
time0=datetime(ncread(Fn,'time'),'convertfrom','posixtime');
spec.f=ncread(Fn,'f');
spec.a1=ncread(Fn,'a1');
spec.b1=ncread(Fn,'b1');
spec.Zz=ncread(Fn,'pzz');

%% Calculate spectra
param=lpp_directional_wave_parameters(spec,'F0',0.1,'F1',0.58);
param.time=time0;

%% Correction for magnetic declanation
param.meandir=param.meandir+9;
param.pdir=param.pdir+9;

%% Write to netcdf
Fn=sprintf('netcdf/WR_dir_param_30min_%s%.0f.nc',loc,yyyy);
lpp_write_netcdf_dir_param(Fn,param,time0,'name',loc,'depth',22,'fs',1.28,'longitude',24+58.35/60,'latitude',60+07.40/60,'source','Waverider Mk-III');
