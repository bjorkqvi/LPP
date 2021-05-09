function lpp_write_netcdf_param(filename,param,time0,varargin)
%lpp_write_netcdf_param(filename,param,time0,varargin)
%Example: lpp_write_netcdf_raw('Suomenlinna_2020_depl_04_01.nc',signal,time0,'name','Suomenlinna','run_index','2020_depl_04_01')
% -------------------------------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   filename = String
%   param = Struct with the wave parameters (ignores possible time-field).
%   time0 = datetime. Starting time of each spectrum.
% [Optional]
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
defaultFs=5.12;
defaultLongitude = []; 
defaultLatitude = [];
defaultName = [];
defaultDepth = [];
defaultRunIndex = [];
defaultNote = [];

p = inputParser;
addRequired(p,'Filename', @ischar);
addRequired(p,'Param', @isstruct);
addRequired(p,'Time0',@isdatetime);
addParameter(p,'fs',defaultFs, @isnumeric);
addParameter(p,'longitude',defaultLongitude,@isnumeric);
addParameter(p,'latitude',defaultLatitude,@isnumeric);
addParameter(p,'run_index',defaultRunIndex, @(x) (isscalar(x) || ischar(x)));
addParameter(p,'depth',defaultDepth);
addParameter(p,'name',defaultName);
addParameter(p,'note',defaultNote);
parse(p,filename,param,time0,varargin{:});

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

Ntime=length(time0);

dimid.T = netcdf.defDim(ncid,'time', Ntime);

% Time
varid = netcdf.defVar(ncid,'time','double',dimid.T);         
netcdf.putAtt(ncid,varid,'standard_name','time');
netcdf.putAtt(ncid,varid,'long_name','starting time of each block of data');
netcdf.putAtt(ncid,varid,'units','milliseconds since 1970-01-01T00:00:00');
netcdf.defVarFill(ncid,varid,false,fillValue);
netcdf.putVar(ncid,varid,posixtime(time0));

% Define metadata
std_name.hs='hs';
long_name.hs='significant wave height hm0';
units.hs='metres';

std_name.tp='tp';
long_name.tp='wave period at spectral peak';
units.tp='seconds';

std_name.tm01='tm01';
long_name.tm01='inverse of the mean frequency tm01';
units.tm01='seconds';

std_name.tm_10='tm_10';
long_name.tm_10='mean wave period tm_10';
units.tm_10='seconds';

std_name.tm02='tm02';
long_name.tm02='spectral zero-crossing wave period tm02';
units.tm02='seconds';

% Displacement data
fn=fieldnames(p.Results.Param);
for n=1:length(fn)
    pp=fn{n};
    if ~strcmp(pp,'time')
        varid = netcdf.defVar(ncid,pp,'double',dimid.T);         
        netcdf.putAtt(ncid,varid,'standard_name',std_name.(pp));
        netcdf.putAtt(ncid,varid,'long_name',long_name.(pp));
        netcdf.putAtt(ncid,varid,'units',units.(pp));
        netcdf.defVarFill(ncid,varid,false,fillValue);
        netcdf.putVar(ncid,varid,p.Results.Param.(pp));
    end
end


netcdf.close(ncid)




end
