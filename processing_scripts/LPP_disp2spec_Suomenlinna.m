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
Fn=sprintf('netcdf/up_30min_%s%.0f_%s.nc',loc,yyyy,run_index); 

%% Get times and raw data blocks
time0=datetime(ncread(Fn,'time'),'convertfrom','posixtime');
displacement=ncread(Fn,'signal');

%% Calculate spectra
blocks=lpp_chop_timeseries(displacement); % Chop is up for Welch method
spec=lpp_spectrum_welch(blocks);

%% Write to netcdf
Fn=sprintf('netcdf/spec_30min_%s%.0f_%s.nc',loc,yyyy,run_index);
lpp_write_netcdf_spec(Fn,spec,time0,'name',loc,'run_index',run_index);
