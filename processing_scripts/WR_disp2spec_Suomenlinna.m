clear
close all

addpath('../LPP/functions/')

%% Location and deployment settings
loc='Suomenlinna';
yyyy=2020;
Fn=sprintf('netcdf/WR_up_30min_%s%.0f.nc',loc,yyyy); 

%% Get times and raw data blocks
time0=datetime(ncread(Fn,'time'),'convertfrom','posixtime');
displacement=ncread(Fn,'signal');

%% Calculate spectra
blocks=lpp_chop_timeseries(displacement,'fs',1.28); % Chop is up for Welch method
spec=lpp_spectrum_welch(blocks,'fs',1.28);

%% Write to netcdf
Fn=sprintf('netcdf/WR_spec_30min_%s%.0f.nc',loc,yyyy);
lpp_write_netcdf_spec(Fn,spec,time0,'name',loc,'depth',22,'fs',1.28,'longitude',24+58.35/60,'latitude',60+07.40/60,'source','Waverider Mk-III');
