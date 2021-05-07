function lpp_write_netcdf_nrdata(filename,acc,time,time0,varargin)
%lpp_write_netcdf_nrdata(filename,signal,time0,varargin)
%Example: lpp_write_netcdf_nrdata('AccX_Suomenlinna_2020_depl_04_01.nc',signal,time0,'fs',5.12,'name','Suomenlinna','run_index','2020_depl_04_01')
% -------------------------------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   filename = String
%   signal = Acceleration time series (vector)
%   time = Buoy time stamp (vector)
%   time0 = Start time of deployment (datetime)
% [Optional]
%   'fs': Sampling frequency [Hz] (default = 50).
%   'longitude': Scalar (default = N/A)
%   'latitude': Scalar (default = N/A)
%   'depth': Scalar (default = N/A)
%   'name': String (default = N/A)
%   'run_index': String or Scalar (default = N/A)
%   'note': default = N/A
% -------------------------------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------------------------------
%% Parsing input
defaultFs = 50; % Sampling frequency [Hz]
defaultLongitude = []; 
defaultLatitude = [];
defaultName = [];
defaultDepth = [];
defaultRunIndex = [];
defaultNote = [];

p = inputParser;
addRequired(p,'Filename', @ischar);
addRequired(p,'Acc', @validSignal);
addRequired(p,'Time',@validSignal);
addRequired(p,'Time0',@isdatetime);
addParameter(p,'fs',defaultFs, @isnumeric);
addParameter(p,'longitude',defaultLongitude,@isnumeric);
addParameter(p,'latitude',defaultLatitude,@isnumeric);
addParameter(p,'run_index',defaultRunIndex, @(x) (isscalar(x) || ischar(x)));
addParameter(p,'depth',defaultDepth);
addParameter(p,'name',defaultName);
addParameter(p,'note',defaultNote);
parse(p,filename,acc,time,time0,varargin{:});

    if exist(filename,'file')
        answer=input(sprintf('%s exists. Overwrite? (y/n): ',filename),'s');
        if strcmp(answer,'y')
            delete(filename);
            ncid=netcdf.create(filename,'netcdf4');   
        else
            return
        end
    else
         ncid=netcdf.create(filename,'netcdf4');   
       
    end

NC_GLOBAL = netcdf.getConstant('NC_GLOBAL');

% Set attributes
netcdf.putAtt(ncid, NC_GLOBAL,'institution','Department of Marine Systems, Tallinn University of Technology');
netcdf.putAtt(ncid, NC_GLOBAL,'source','LainePoiss wave buoy');
netcdf.putAtt(ncid, NC_GLOBAL,'sampling_freq',p.Results.fs);
netcdf.putAtt(ncid, NC_GLOBAL,'start_time_posix',posixtime(p.Results.Time0));
netcdf.putAtt(ncid, NC_GLOBAL,'CreationDate',datestr(now,'yyyy-mm-ddTHH:MM:SS'));

%% Optional attributes
fns={'longitude','latitude','name','depth','run_index','note'};
for n=1:length(fns)
    fn=fns{n};
   if ~isempty(p.Results.(fn))
       netcdf.putAtt(ncid, NC_GLOBAL,fn,p.Results.(fn));
   end
end





fillValue = NaN;

Nsamples=size(p.Results.Acc,1);

dimid.samp = netcdf.defDim(ncid,'samples',Nsamples);

% Buoy time stamp
varid = netcdf.defVar(ncid,'time','double',dimid.samp);         
netcdf.putAtt(ncid,varid,'standard_name','time');
netcdf.putAtt(ncid,varid,'long_name','time stamp of wave buoy');
netcdf.putAtt(ncid,varid,'units',sprintf('milliseconds since %s',datestr(p.Results.Time0)));
netcdf.defVarFill(ncid,varid,false,fillValue);
netcdf.putVar(ncid,varid,p.Results.Time);

% Displacement data
varid = netcdf.defVar(ncid,'acc','double',dimid.samp);         
netcdf.putAtt(ncid,varid,'standard_name','acc');
netcdf.putAtt(ncid,varid,'long_name','acceleration of wave buoy');
netcdf.putAtt(ncid,varid,'units','metres');
netcdf.defVarFill(ncid,varid,false,fillValue);
netcdf.putVar(ncid,varid,p.Results.Acc);



netcdf.close(ncid)




end


function TF=validSignal(x)
    TF=false;
    if ~(isvector(x))
        error('Data and time input have to be vectors.');
    else
        TF=true;
    end
end