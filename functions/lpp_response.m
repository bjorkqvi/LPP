function rf=lpp_response(f,varargin)

%lpp_response: Calculate the response function for given linear frequency f. 
%Example: rf = lpp_response(f)
% ------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   f = Frequency vector. [Hz]
% [Optional]
%  fLow: Below this freq response is set to zero
%  fHigh = Above this freq f-2 division
% -------------------------------------------------------------------------------------------------------
% Output:
%   rf = response function.
% -------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------


%% Parsing input
defaultFLow = 0.04; % [Hz]
defaultFHigh = 0.05; % [Hz]

p = inputParser;
validVector = @(x) isnumeric(x) && isvector(x);
validScalar = @(x) isnumeric(x) && isscalar(x);
addRequired(p,'f',validVector);
addParameter(p,'fLow',defaultFLow,validScalar);
addParameter(p,'fHigh',defaultFHigh,validScalar);

parse(p,f,varargin{:});
p.Results; % diagnostic

%% Calcuate response function
f = p.Results.f;
fLow = p.Results.fLow;
fHigh = p.Results.fHigh;
N = size(f,1);
rf = zeros(N,1);
for ind=1:N
    if (gt(f(ind),-fLow) && lt(f(ind),fLow)) 
        rf(ind,1)=0;
    elseif (ge(f(ind),fLow) && le(f(ind),fHigh))
        rf(ind,1)=-0.5*(1-cos(pi*(f(ind)-fLow)/(fHigh-fLow)))*power(1/(2*pi*f(ind)),2);
    elseif (ge(f(ind),-fHigh) && le(f(ind),-fLow))
        rf(ind,1)=-0.5*(1-cos(pi*(f(ind)-fLow)/(fHigh-fLow)))*power(1/(2*pi*f(ind)),2);
    else
        rf(ind,1)=-1/power(2*pi*f(ind),2);
    end
end
