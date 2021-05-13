function param=lpp_directional_wave_parameters(spec,varargin)
%param=lpp_wave_parameters: Calculates wave parameters from power spectra.
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
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% ---------------------------------------------------------------------------------------------------------

%% Parsing input
defaultF0 = 0.05; % Lowest frequency to use [Hz] (default 0.05)
defaultF1 = 1.28; % Highest frequency to use [Hz] (default 1.28)
defaultList = {'meandir','pdir','meanspread','pspread'};%,'tm01','tm_10','tm02'}; % List of parameters

p = inputParser;
validList = @(x) iscell(x) && ischar(x{1});
addRequired(p,'spec', @validSpec);
addParameter(p,'F0',defaultF0, @isnumeric);
addParameter(p,'F1',defaultF1, @isnumeric);
addParameter(p,'List',defaultList, validList);
parse(p,spec,varargin{:});

%% Decode spectral input and censor frequencies
f=p.Results.spec.f; % n x 1 vector
E=p.Results.spec.Zz; % n x m matrix with m being number of spectra
a1=p.Results.spec.a1;
b1=p.Results.spec.b1;

%% Censor the spectra to highest and lowest freqeuncy
ind0=find(f>=p.Results.F0,1,'first');
ind1=find(f<=p.Results.F1,1,'last');
f=f(ind0:ind1);
E=E(ind0:ind1,:);
[a,b]=size(E);
a1=a1(ind0:ind1,:);
b1=b1(ind0:ind1,:);
fmat=repmat(f,1,size(E,2));

%% Moments
m0=trapz(f,E);

df=f(2)-f(1);
%% Calculate actual parameters
for pp=1:length(p.Results.List)
    parameter=p.Results.List{pp};

    switch parameter
        case 'meandir' 
            a1_mean=sum(a1.*E.*df./m0);
            b1_mean=sum(b1.*E.*df./m0);
            param.meandir(:,1)=round(atan2d(a1_mean,b1_mean)+180);
        case 'meanspread'
            a1_mean=sum(a1.*E.*df./m0);
            b1_mean=sum(b1.*E.*df./m0);
            mm1=sqrt(power(a1_mean,2)+power(b1_mean,2));
            param.meanspread(:,1)=(sqrt(2-2*mm1))*180/pi;
        case 'pdir'
            dirnaut=round(atan2d(a1,b1)+180); 
            [~,kus]=max(E,[],1); 
            
            for ind=1:b
                
            param.pdir(ind,1)=dirnaut(kus(ind),ind);
        
            end
        case 'pspread'
            mm1=sqrt(power(a1,2)+power(b1,2));
            
            fspread=sqrt(2*(1-mm1))*180/pi;
            
            [~,kus]=max(E,[],1); 
            for ind=1:b
                
            param.pspread(ind,1)=fspread(kus(ind),ind);
            end
        otherwise
            warning('Unknown wave parameter %s ignored.',parameter)
    end
end


function TF=validSpec(spec)
    TF=false;
    
    if isstruct(spec) && isfield(spec,'f') && isfield(spec,'Zz') && isfield(spec,'a1') && isfield(spec,'b1')
        TF=true;
    else
        error('First input has to be a struct with fields .Zz and .f');
    end
end

end

