function param=lpp_check_factor(spec,varargin)
%param=lpp_check_factor: Calculates the check factor
%Example: param = lpp_directional_wave_parameters(spec,'list',{'meandir','pdir'},'f0',0.05,'f1',1.28)
% ---------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   spec = Struct spec.f (m x 1 linear frequency vector) and spec.auto (m x 3 spectral density matrix)
%    and spec.a1 and spec.b1 (m x 1 fourier coefficient vectors).
% [Optional]
%   'list': Cell of parameters to calculate (default: include all, i.e. {'meandir','pdir','meanspread','pspread'}).
%   'f0': Lowest frequency included in integration [Hz] (default = 0.05).
%   'f1': Highest frequency included in integration [Hz] (default = 1.28).
% ---------------------------------------------------------------------------------------------------------
% Output:
%   param = Struct with requested parameter time series as fields.
% ---------------------------------------------------------------------------------------------------------
% Reference
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% ---------------------------------------------------------------------------------------------------------

%% Parsing input
defaultF0 = 0.05; % Lowest frequency to use [Hz] (default 0.05)
defaultF1 = 1.28; % Highest frequency to use [Hz] (default 1.28)
defaultH=1000;
p = inputParser;
validList = @(x) iscell(x) && ischar(x{1});
addRequired(p,'spec', @validSpec);
addParameter(p,'F0',defaultF0, @isnumeric);
addParameter(p,'F1',defaultF1, @isnumeric);
addParameter(p,'h',defaultH, @isnumeric);
parse(p,spec,varargin{:});

%% Decode spectral input and censor frequencies
f=p.Results.spec.f; % n x 1 vector
Cxx=p.Results.spec.Xx; % n x m matrix with m being number of spectra
Cyy=p.Results.spec.Yy;
Czz=p.Results.spec.Zz;

%% Censor the spectra to highest and lowest freqeuncy
ind0=find(f>=p.Results.F0,1,'first');
ind1=find(f<=p.Results.F1,1,'last');
f=f(ind0:ind1);
Cxx=Cxx(ind0:ind1,:);
Cyy=Cyy(ind0:ind1,:);
Czz=Czz(ind0:ind1,:);


%% Calculate check factor
%k=2*pi./wavelength(f,p.Results.h);
%k=repmat(k,1,size(Cxx,2));
param.R=sqrt((Cxx+Cyy)./Czz);
param.f=f(:);
function TF=validSpec(spec)
    TF=false;
    
    if isstruct(spec) && isfield(spec,'f') && isfield(spec,'Zz') && isfield(spec,'Yy') && isfield(spec,'Xx')
        TF=true;
    else
        error('First input has to be a struct with fields .Pzz and .f');
    end
end

end

function L=wavelength(f,h);

%  f, wave frequency [Hz]
%  h, water depth [m]

w=2.*pi.*f;
dum1=(w.^2).*h./9.81;
dum2=dum1+(1.0+0.6522*dum1+0.4622*dum1.^2+0.0864*dum1.^4+0.0675*dum1.^5).^(-1);
L=sqrt(9.81*h.*dum2.^(-1))./f; % [m]

end

