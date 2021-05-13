%% LPP_acc2disp_30min.m
% -------------------------------------------------------------------------------------------------------------------------------
% This script converts accelearation data to chopped up 30 mintute displacement files
% -------------------------------------------------------------------------------------------------------------------------------
% [Reads]
%	Netcdf, e.g. netcdf/AccZ_Suomenlinna2020_depl_04_01.nc
% [Writes]
%	Netcdf, e.g. netcdf/up_30min_Suomenlinna2020_depl_04_01.nc
% [Pre-processing scripts]
%	LPP_acc_nr2nc_Suomenlinna.m
% [Post-processing scripts]
%	LPP_disp2spec_Suomenlinna.m
%	LPP_disp2cross_spec_Suomenlinna.m
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
%Fn=sprintf('netcdf/AccZ_%s%.0f_%s.nc',loc,yyyy,run_index); 
Fn=sprintf('netcdf/AccX_%s%.0f_%s.nc',loc,yyyy,run_index) 
%Fn=sprintf('netcdf/AccY_%s%.0f_%s.nc',loc,yyyy,run_index) 

%% Data settings
fsIn=50;
fsOut=5.12;
desired_length=30; % [min] Final length
padding=1; % [min] Read this much extra to account for lost data from filtering etc.
time_shift=60; % Seconds/month

%% Get start time of deployment and read in data
time0=datetime(ncreadatt(Fn,'/','start_time_posix'),'convertfrom','posixtime');
acc=ncread(Fn,'acc');
acc_time=ncread(Fn,'time');

%% Calculate wanted UTC start times that cover the deployment
time_start=time0+seconds(acc_time(1)/1000);
time_end=time0+seconds(acc_time(end)/1000);
timevec=[roundto30min(time_start)-minutes(desired_length):minutes(desired_length):roundto30min(time_end)+minutes(desired_length)]'; % This only works with 30 minute blocks!!!

%% Read blocks 
%Allow for FIR and transience and shift the desired UTC times to LP-times
timevec=lpp_shift_time(timevec-minutes(1),time_shift,'UTCtoLP'); 
block_length=(desired_length+2*padding)*60*fsIn; % Length of block in points
[block, block_time]=lpp_get_block(acc,acc_time,time0,timevec,block_length); % Get 32 minute blocks

clear az az_time timevec

%% Go from acceleration to elevation
%----------------------------------------------------------------------------------------------------
[block, block_time]=lpp_check_for_gaps(block, block_time,200); % Interpolate gaps shorter than 200 ms

signal_filtered = lpp_fir(block); 

signal_interpolated = lpp_interpolate(signal_filtered,'fsIn',fsIn,'fsOut',fsOut,'method','nearest');

displacement = lpp_integrate(signal_interpolated,fsOut,'denoise',false);
%----------------------------------------------------------------------------------------------------

%% Cut down to exactly 30 minutes
fir_cut=round((size(block,1)-size(signal_filtered,1))*fsOut/fsIn); % FIR cut this many points normalized to the final frequency
int_cut=round(30*fsOut); % Integration cut this many point from each end
n_start=round(padding*60*fsOut)-fir_cut-int_cut; % Need to cut this much more from start to compensate for that we starten 1 minute becore 00/30.
n_length=desired_length*60*fsOut; 

displacement=displacement(n_start:n_start+n_length-1,:);
up_time=block_time(n_start:n_start+n_length-1,:);

% Final starting times in UTC to be compared with Waverider
% These should be very close to 00/30
timevec_UTC=roundto30min(lpp_shift_time(time0+seconds(up_time(1,:)/1000)',time_shift,'LPtoUTC')+minutes(1)); 

%% Write to netcdf
Fn=sprintf('netcdf/east_30min_not_denoised_%s%.0f_%s.nc',loc,yyyy,run_index);
lpp_write_netcdf_raw(Fn,displacement,timevec_UTC,'name',loc,'run_index',run_index);
