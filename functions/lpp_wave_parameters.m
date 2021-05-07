function param=lpp_wave_parameters(spec,varargin)
%param=lpp_wave_parameters: Calculates wave parameters from power spectra.
%Example: param = lpp_wave_parameters(spec,'list',{'hs','tp'},'f0',0.05,'f1',1.28)
% ---------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   spec = Struct spec.f (m x 1 linear frequency vector) and spec.psd (m x n spectral density matrix)
% [Optional]
%   'list': Cell of parameters to calculate (default: include all, i.e. {'hs','tp','tm01','tm_10','tm02'}).
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
defaultList = {'hs','tp','tm01','tm_10','tm02'}; % List of parameters

p = inputParser;
validList = @(x) iscell(x) && ischar(x{1});
addRequired(p,'Spec', @validSpec);
addParameter(p,'F0',defaultF0, @isnumeric);
addParameter(p,'F1',defaultF1, @isnumeric);
addParameter(p,'List',defaultList, validList);
parse(p,spec,varargin{:});

%% Decode spectral input and censor frequencies
f=p.Results.Spec.f; % n x 1 vector
E=p.Results.Spec.psd; % n x m matrix with m being number of spectra


%% Censor the spectra to highest and lowest freqeuncy
ind0=find(f>=p.Results.F0,1,'first');
ind1=find(f<=p.Results.F1,1,'last');
f=f(ind0:ind1);
E=E(ind0:ind1,:);
fmat=repmat(f,1,size(E,2));

%% Moments
m0=trapz(f,E)';
m1=trapz(f,E.*fmat)';
m_1=trapz(f,E./fmat)';
m2=trapz(f,E.*fmat.^2)';

%% Calculate actual parameters
for pp=1:length(p.Results.List)
    parameter=p.Results.List{pp};

    switch parameter
        case 'hs'
            param.hs=4*sqrt(m0);
        case 'tm01'
            param.tm01=m0./m1;
        case 'tm_10'
            param.tm_10=m_1./m0;
        case 'tm02'
            param.tm02=sqrt(m0./m2);
        case 'tp'
            param.tp=parabolic_tp_fit(f,E);
        otherwise
            warning('Unknown wave parameter %s ignored.',parameter)
    end
end


function TF=validSpec(spec)
    TF=false;
    
    if isstruct(spec) && isfield(spec,'f') && isfield(spec,'psd')
        TF=true;
    else
        error('First input has to be a struct with fields .psd and .f');
    end
end

end
function tp=parabolic_tp_fit(f,E)
    % This function has been taken and modified from the code by Heidi Pettersson
    for n=1:size(E,2)
        [~,ind]=max(E(:,n));

        if ind==length(f)
            fm=f(length(f));
        elseif ind==1
            fm=f(1);
        else
            x0=f(ind-1);
            x1=f(ind);
            x2=f(ind+1);
            y0=E(ind-1,n);
            y1=E(ind,n);
            y2=E(ind+1,n);
            a1=(y0-y1)*(x2-x0)*(x2-x0)-(y0-y2)*(x1-x0)*(x1-x0);
            a2=(x1-x0)*(y0-y2)-(x2-x0)*(y0-y1);
            fm=(x0-(0.5*a1/a2));
        end
        tp(n,1)=1/fm;
    end
end