function lpp_write_netcdf_cross_spec(filename,spec,time0,varargin)
%lpp_write_netcdf_cross_spec(filename,spec,time0,varargin)
%Example: lpp_write_netcdf_cross_spec('Suomenlinna_2020_depl_04_01.nc',spec,time0,'fs',5.12,'name','Suomenlinna','run_index','2020_depl_04_01')
% -------------------------------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   filename = String
%   spec = struct with fields .f and .psd
%   time0 = datetime. Starting time of each block.
% [Optional]
%   'fs': Sampling frequency [Hz] (default = 5.12).
%   'f0': Lowest frequency to write to file [Hz] (default = 0.05).
%   'f1': Highest frequency to write to file [Hz] (default = 1.28).
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
defaultF0 = 0.05; % Lowest frequency to use [Hz] (default 0.05)
defaultF1 = 1.28; % Highest frequency to use [Hz] (default 1.28)
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
addRequired(p,'Spec', @validSpec);
addRequired(p,'Time0',@isdatetime);
addParameter(p,'institution',defaultInstitution, @ischar);
addParameter(p,'source',defaultSource, @ischar);
addParameter(p,'F0',defaultF0, @isnumeric);
addParameter(p,'F1',defaultF1, @isnumeric);
addParameter(p,'fs',defaultFs, @isnumeric);
addParameter(p,'longitude',defaultLongitude,@isnumeric);
addParameter(p,'latitude',defaultLatitude,@isnumeric);
addParameter(p,'run_index',defaultRunIndex, @(x) (isscalar(x) || ischar(x)));
addParameter(p,'depth',defaultDepth);
addParameter(p,'name',defaultName);
addParameter(p,'note',defaultNote);
parse(p,filename,spec,time0,varargin{:});

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

%% Restrict spectra to certain frequencies
f=p.Results.Spec.f; % n x 1 vector
ind0=find(f>=p.Results.F0,1,'first');
ind1=find(f<=p.Results.F1,1,'last');
f=f(ind0:ind1);
fn=fieldnames(p.Results.Spec);
for n=1:length(fn)
    pp=fn{n};
    if ~strcmp('f',pp)
      E.(pp)=p.Results.Spec.(pp); % n x m matrix with m being number of spectra  
      E.(pp)=E.(pp)(ind0:ind1,:);
      % Clean out NaN-spectra  
      r=any(isnan(E.(pp)));
      E.(pp)=E.(pp)(:,~r);
    end
end
        
time0=time0(~r);



Ntime=size(E.a1,2);
Nfreq=size(f,1);

dimid.T = netcdf.defDim(ncid,'time', Ntime);
dimid.f = netcdf.defDim(ncid,'f',Nfreq);

% Time
varid = netcdf.defVar(ncid,'time','double',dimid.T);         
netcdf.putAtt(ncid,varid,'standard_name','time');
netcdf.putAtt(ncid,varid,'long_name','starting time of each spectra');
netcdf.putAtt(ncid,varid,'units','seconds since 1970-01-01T00:00:00');
netcdf.defVarFill(ncid,varid,false,fillValue);
netcdf.putVar(ncid,varid,posixtime(time0));


% Define metadata
std_name.Xx='pxx';
long_name.Xx='power spectra of east displacement';
units.Xx='m*m/Hz';

std_name.Yy='pyy';
long_name.Yy='power spectra of north displacement';
units.Yy='m*m/Hz';

std_name.Zz='pzz';
long_name.Zz='power spectra of up displacement';
units.Zz='m*m/Hz';


std_name.a1='a1';
long_name.a1='first fourier coefficient a1';
units.a1='-';

std_name.b1='b1';
long_name.b1='first fourier coefficient b1';
units.b1='-';


std_name.Qzx='qzx';
long_name.Qzx='cross spectra up-east';
units.Qzx='m*m/Hz';

std_name.Qzy='qzy';
long_name.Qzy='cross spectra up-north';
units.Qzy='m*m/Hz';

for n=1:length(fn)
    pp=fn{n};
    if strcmp('f',pp)
        % Frequency
        varid = netcdf.defVar(ncid,'f','double',dimid.f);         
        netcdf.putAtt(ncid,varid,'standard_name','frequency');
        netcdf.putAtt(ncid,varid,'long_name','linear frequency of the power spectrum');
        netcdf.putAtt(ncid,varid,'units','Hz');
        netcdf.defVarFill(ncid,varid,false,fillValue);
        netcdf.putVar(ncid,varid,f);

    else
        
        % Spectra
        varid = netcdf.defVar(ncid,std_name.(pp),'double',[dimid.f,dimid.T]);         
        netcdf.putAtt(ncid,varid,'standard_name',std_name.(pp));
        netcdf.putAtt(ncid,varid,'long_name',long_name.(pp));
        netcdf.putAtt(ncid,varid,'units',units.(pp));
        netcdf.defVarFill(ncid,varid,false,fillValue);
        netcdf.putVar(ncid,varid,E.(pp));
    end
end

netcdf.close(ncid)




end


function TF=validSpec(x)
    TF=false;
    if ~(isstruct(x))
        error('Second input has to be a struct');
    elseif ~(isfield(x,'f') && isvector(x.f))    
        error('Spectrum needs to contain a field spec.f which is a vector');
    else
        TF=true;
    end
end
