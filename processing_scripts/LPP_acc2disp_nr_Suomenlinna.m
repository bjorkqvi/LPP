%% LPP_acc2disp_nr.m
% -------------------------------------------------------------------------------------------------------------------------------
% This script reads in NR-files (containing acceleration data) and integrates them to displacement time series
% -------------------------------------------------------------------------------------------------------------------------------
% [Reads]
%	NR-files (original LainePoiss ascii)
% [Writes]
%	Netcdf, e.g.    netcdf/up_NR_Suomenlinna2020_depl_04_01.nc
%                   netcdf/east_NR_Suomenlinna2020_depl_04_01.nc
%                   netcdf/north_NR_Suomenlinna2020_depl_04_01.nc
% [Pre-processing scripts]
%	None
% [Post-processing scripts]
%	LPP_disp2spec_Suomenlinna.m (doesn't exist yet!)
% -------------------------------------------------------------------------------------------------------------------------------
% This script is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------------------------------

clear
close all

addpath('../LPP/functions/');

loc='Suomenlinna';
yyyy=2010;
run_index='depl_04_01'; % Choose location (folder name)

%% Data settings
time_shift=60; % Seconds/month, if the clock is slowly shifting


system(sprintf('ls %s/%s/*NR*.txt > %s/%s/NR.list',loc,run_index,loc,run_index));
filelist.lp=importdata(sprintf('%s/%s/NR.list',loc,run_index));

ct=1;
for n=14:(length(filelist.lp)-184)
%for n=3491:3492%(length(filelist.lp)-184)
    disp(n)
    fn=filelist.lp{n};
    
    nr=lpp_read_nr(fn);
    
    time0(ct)=nr.header.time0+seconds(nr.data.Time(1,1)/1000);
    
    signal_filtered = lpp_fir([nr.data.AccX nr.data.AccY nr.data.AccZ]); 

    signal_interpolated = lpp_interpolate(signal_filtered,'fsIn',50,'fsOut',5.12,'method','nearest');
    
    displacement(:,:,ct) = lpp_integrate(signal_interpolated,5.12,'denoise', false);

    ct=ct+1;
end

%% The time drifts approximately 60 seconds per month
time0=lpp_shift_time(time0,time_shift,'LPtoUTC'); 

%% Save data to files
Fn=sprintf('netcdf/up_NR_%s%.0f_%s.nc',loc,yyyy,run_index);
lpp_write_netcdf_raw(Fn,squeeze(displacement(:,3,:)),time0,'name',loc,'run_index',run_index);
Fn=sprintf('netcdf/east_NR_%s%.0f_%s.nc',loc,yyyy,run_index);
lpp_write_netcdf_raw(Fn,squeeze(displacement(:,1,:)),time0,'name',loc,'run_index',run_index);
Fn=sprintf('netcdf/north_NR_%s%.0f_%s.nc',loc,yyyy,run_index);
lpp_write_netcdf_raw(Fn,squeeze(displacement(:,2,:)),time0,'name',loc,'run_index',run_index);