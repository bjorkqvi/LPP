%% LPP_disp2spec.m
% -------------------------------------------------------------------------------------------------------------------------------
% This script converts displacement data to wave spectra
% -------------------------------------------------------------------------------------------------------------------------------
% [Reads]
%	Netcdf, e.g. netcdf/up_30min_Suomenlinna2020_depl_04_01.nc
% [Writes]
%	Netcdf, e.g. netcdf/spec_30min_Suomenlinna2020_depl_04_01.nc
% [Pre-processing scripts]
%	LPP_disp2spec_Suomenlinna.m
% [Post-processing scripts]
%	LPP_spec2param_Suomenlinna.m (doesn't exist yet!)
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
Fn.up=sprintf('netcdf/up_30min_%s%.0f_%s.nc',loc,yyyy,run_index); 
Fn.east=sprintf('netcdf/east_30min_not_denoised_%s%.0f_%s.nc',loc,yyyy,run_index); 
Fn.north=sprintf('netcdf/north_30min_not_denoised_%s%.0f_%s.nc',loc,yyyy,run_index); 

%% Get times and raw data blocks
time0=datetime(ncread(Fn.up,'time'),'convertfrom','posixtime');
up=ncread(Fn.up,'signal');
east=ncread(Fn.east,'signal');
north=ncread(Fn.north,'signal');

%% Calculate spectra
blocks.up=lpp_chop_timeseries(up); % Chop is up for Welch method
blocks.east=lpp_chop_timeseries(east); % Chop is up for Welch method
blocks.north=lpp_chop_timeseries(north); % Chop is up for Welch method


cross_spec = lpp_cross_spectrum_welch(blocks.east,blocks.north,blocks.up);

%% Write to netcdf
Fn=sprintf('netcdf/cross_spec_30min_not_denoised_%s%.0f_%s.nc',loc,yyyy,run_index);
lpp_write_netcdf_cross_spec(Fn,cross_spec,time0,'name',loc,'run_index',run_index);
