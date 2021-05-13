%% LPP_cross_spec2param.m
% -------------------------------------------------------------------------------------------------------------------------------
% This calcluates spectram parameters
% -------------------------------------------------------------------------------------------------------------------------------
% [Reads]
%	Netcdf, e.g. netcdf/cross_spec_30min_Suomenlinna2020_depl_04_01.nc
% [Writes]
%	Netcdf, e.g. netcdf/dir_param_30min_Suomenlinna2020_depl_04_01.nc
% [Pre-processing scripts]
%	LPP_cross_spec2param_Suomenlinna.m
% [Post-processing scripts]
%	None
% -------------------------------------------------------------------------------------------------------------------------------
% This script is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------------------------------

clear
close all

addpath('../LPP/functions/')

%% Location and deployment settings
loc='Suomenlinna';
yyyy=2020;
run_index='depl_04_01'; % Choose location (folder name)
Fn=sprintf('netcdf/cross_spec_30min_not_denoised_%s%.0f_%s.nc',loc,yyyy,run_index); 
%% Get times and raw data blocks
time0=datetime(ncread(Fn,'time'),'convertfrom','posixtime');
spec.f=ncread(Fn,'f');
spec.a1=ncread(Fn,'a1');
spec.b1=ncread(Fn,'b1');
spec.Zz=ncread(Fn,'pzz');

%% Calculate spectra
param=lpp_directional_wave_parameters(spec,'F0',0.1,'F1',0.58);
param.time=time0;

%% Write to netcdf
Fn=sprintf('netcdf/dir_param_30min_not_denoised_%s%.0f_%s.nc',loc,yyyy,run_index); 
lpp_write_netcdf_dir_param(Fn,param,time0,'name',loc,'run_index',run_index);
