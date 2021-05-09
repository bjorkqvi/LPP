function lpp_write_netcdf_raw(filename,signal,time0,varargin)
%lpp_write_netcdf_raw(filename,signal,time0,varargin)
%Example: lpp_write_netcdf_raw('Suomenlinna_2020_depl_04_01.nc',signal,time0,'fs',5.12,'name','Suomenlinna','run_index','2020_depl_04_01')
% -------------------------------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   filename = String
%   signal = Matrix with signal (n x t) with n = samples and t = e.g. 30 min blocks
%   time0 = Datetime vector. Starting time of each block.
% [Optional]
%   'fs': Sampling frequency [Hz] (default = 5.12).
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
defaultFs = 5.12; % Sampling frequency [Hz]
defaultLongitude = []; 
defaultLatitude = [];
defaultName = [];
defaultDepth = [];
defaultRunIndex = [];
defaultNote = [];
defaultSource = 'LainePoiss wave buoy';
defaultInstitution = 'Department of Marine Systems, Tallinn University of Technology';

p = inputParser;
addRequired(p,'Filename', @ischar);
addRequired(p,'Signal', @validSignal);
addRequired(p,'Time0',@isdatetime);
addParameter(p,'institution',defaultInstitution, @ischar);
addParameter(p,'source',defaultSource, @ischar);
addParameter(p,'fs',defaultFs, @isnumeric);
addParameter(p,'longitude',defaultLongitude,@isnumeric);
addParameter(p,'latitude',defaultLatitude,@isnumeric);
addParameter(p,'run_index',defaultRunIndex, @(x) (isscalar(x) || ischar(x)));
addParameter(p,'depth',defaultDepth);
addParameter(p,'name',defaultName);
addParameter(p,'note',defaultNote);
parse(p,filename,signal,time0,varargin{:});

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
netcdf.putAtt(ncid, NC_GLOBAL,'sampling_freq',p.Results.fs);
netcdf.putAtt(ncid, NC_GLOBAL,'CreationDate',datestr(now,'yyyy-mm-ddTHH:MM:SS'));

%% Optional attributes
fns={'institution','source','longitude','latitude','name','depth','run_index','note'};
for n=1:length(fns)
    fn=fns{n};
   if ~isempty(p.Results.(fn))
       netcdf.putAtt(ncid, NC_GLOBAL,fn,p.Results.(fn));
   end
end





fillValue = NaN;

Ntime=size(signal,2);
Nsamples=size(signal,1);

dimid.T = netcdf.defDim(ncid,'time', Ntime);
dimid.samp = netcdf.defDim(ncid,'samples',Nsamples);

% Time
varid = netcdf.defVar(ncid,'time','double',dimid.T);         
netcdf.putAtt(ncid,varid,'standard_name','time');
netcdf.putAtt(ncid,varid,'long_name','starting time of each block of data');
netcdf.putAtt(ncid,varid,'units','seconds since 1970-01-01T00:00:00');
netcdf.defVarFill(ncid,varid,false,fillValue);
netcdf.putVar(ncid,varid,posixtime(time0));

% Displacement data
varid = netcdf.defVar(ncid,'signal','double',[dimid.samp,dimid.T]);         
netcdf.putAtt(ncid,varid,'standard_name','signal');
netcdf.putAtt(ncid,varid,'long_name','displacement signal of wave buoy');
netcdf.putAtt(ncid,varid,'units','metres');
netcdf.defVarFill(ncid,varid,false,fillValue);
netcdf.putVar(ncid,varid,signal);



netcdf.close(ncid)




end


function TF=validSignal(x)
    TF=false;
    if ~(isnumeric(x))
        error('Second input have to be a numeric matrix.');
    else
        TF=true;
    end
end
