function signal_interpolated=lpp_interpolate(signal,varargin)

%accInterp=lpp_interpolate(accFilt,fsIn,fsOut,varargin)

%lpp_interpolate: Interpolates signal to a desired frequency
%Example: accInterp = lpp_interpolate(accFilt,'fsIn',50,'fsOut',5.12,'method','linear')
% ------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal = Matrix with rows being the time axis (one time series per column).

% [Optional]
%  'method': Which method to use (default: 'nearest', possibility:
%  'linear')
%   fsIn = Sampling frequency of input signal
%   fsOut = Sampling frequency of output signal

% -------------------------------------------------------------------------------------------------------
% Output:
%   singal_interpolated = Interpolated signal.
% -------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------

%% Parsing input
defaultFsIn= 50; % Method
defaultFsOut= 5.12;
defaultMethod= 'nearest'; % Method

p = inputParser;
validMatrix = @(x) isnumeric(x) && (size(x,1)>2);
validScalar = @(x) isnumeric(x) && isscalar(x);
addRequired(p,'signal',validMatrix);
addParameter(p,'fsIn',defaultFsIn,validScalar);
addParameter(p,'fsOut',defaultFsOut,validScalar);
addParameter(p,'method',defaultMethod,@ischar);

parse(p,signal,varargin{:});
p.Results; % diagnostic
%%
N=size(p.Results.signal,1);  
interpTo=1:(p.Results.fsIn/p.Results.fsOut):N;
signal_interpolated=interp1(1:N,p.Results.signal,interpTo,p.Results.method); 

if isvector(signal_interpolated)
    signal_interpolated=signal_interpolated';
end
end