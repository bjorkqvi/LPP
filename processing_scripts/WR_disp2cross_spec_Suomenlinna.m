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
Fn.up=sprintf('netcdf/WR_up_30min_%s%.0f.nc',loc,yyyy); 
Fn.east=sprintf('netcdf/WR_east_30min_%s%.0f.nc',loc,yyyy); 
Fn.north=sprintf('netcdf/WR_north_30min_%s%.0f.nc',loc,yyyy); 

%% Get times and raw data blocks
time0=datetime(ncread(Fn.up,'time'),'convertfrom','posixtime');
up=ncread(Fn.up,'signal');
east=ncread(Fn.east,'signal');
north=ncread(Fn.north,'signal');

blocks.up=lpp_chop_timeseries(up,'fs',1.28); % Chop is up for Welch method
blocks.east=lpp_chop_timeseries(east,'fs',1.28); % Chop is up for Welch method
blocks.north=lpp_chop_timeseries(north,'fs',1.28); % Chop is up for Welch method


%% Calculate spectra
cross_spec = lpp_cross_spectrum_welch(blocks.east,blocks.north,blocks.up,'fs',1.28);



return
%% Write to netcdf
Fn.out=sprintf('netcdf/WR_cross_spec_30min_%s%.0f.nc',loc,yyyy);
lpp_write_netcdf_cross_spec(Fn.out,cross_spec,time0,'name',loc,'depth',22,'fs',1.28,'longitude',24+58.35/60,'latitude',60+07.40/60,'source','Waverider Mk-III');

%% Get times and raw data blocks
time0=datetime(ncread(Fn.up,'time'),'convertfrom','posixtime');







