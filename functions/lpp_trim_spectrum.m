function spec_trimmed = lpp_trim_spectrum(spec,varargin)
%spec_trimmed = lpp_trim_spectrum: Trims the power spectrum to a certain frequency range.
%Example: spec_trimmed = lpp_trim_spectrum(spec,'f0',0,'f1',1.28)
% -------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   spec = A struct containing spec(n).f (linear frequency vector) and spec(n).psd (power spectrum)
% [Optional]
%   'f0': Lowest frequency to be included [Hz] (default = 0).
%   'f1': Highest frequency to be included [Hz] (default = 1.28).
% -------------------------------------------------------------------------------------------------
% Output:
%   spec_trimmed = A struct containing spec(n).f and spec(n).psd
% -------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------

%% Parsing input
defaultF0 = 0; % Lowest frequency [Hz]
defaultF1 = 1.28; % Highest frequency [Hz]

p = inputParser;
addRequired(p,'Spec', @validSpec);
addParameter(p,'F0',defaultF0, @isnumeric);
addParameter(p,'F1',defaultF1, @isnumeric);
parse(p,spec,varargin{:});

p.Results; % diagnostic

r=p.Results.Spec(1).f>=p.Results.F0 & p.Results.Spec(1).f<=p.Results.F1;

for n=1:length(spec)
    spec_trimmed(n).f=p.Results.Spec(n).f(r);
    spec_trimmed(n).psd=p.Results.Spec(n).psd(r);
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