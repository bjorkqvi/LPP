function lpp_write_netcdf_dir_param(filename,param,time0,varargin)
%lpp_write_netcdf_dir_param(filename,param,time0,varargin)
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
defaultSource = 'LainePoiss wave buoy';
defaultInstitution = 'Department of Marine Systems, Tallinn University of Technology';

p = inputParser;
addRequired(p,'Filename', @ischar);
addRequired(p,'Param', @isstruct);
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
fns={'institution','source','longitude','latitude','name','depth','run_index','note'};
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
netcdf.putAtt(ncid,varid,'units','seconds since 1970-01-01T00:00:00');
netcdf.defVarFill(ncid,varid,false,fillValue);
netcdf.putVar(ncid,varid,posixtime(time0));

% Define metadata
std_name.meandir='meandir';
long_name.meandir='mean wave direction from';
units.meandir='degrees';

std_name.pdir='pdir';
long_name.pdir='mean wave direction from at spectral peak';
units.pdir='degrees';

std_name.meanspread='meanspread';
long_name.meanspread='mean spreading';
units.meanspread='degrees';

std_name.pspread='pspread';
long_name.pspread='spreading at spectral peak';
units.pspread='degrees';


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
