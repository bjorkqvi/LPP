function signal_chopped = lpp_chop_timeseries(signal,varargin)
%lpp_chop_timeseries: Chops up a time series to be used for the Welch method.
%Example: signal_chopped = lpp_chop_timeseries(signal,'fs',5.12,'segmentlength',100,'overlap',50)
% ------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal = Matrix with rows being the time axis (one time series per column).
% [Optional]
%   'fs': Sampling frequency [Hz] (default = 5.12).
%   'segmentlength': Length of one segment [s] (default = 100).
%   'overlap': Overlap of segments [%] (default = 50). Rounded down to points.
% -------------------------------------------------------------------------------------------------------
% Output:
%   signal_chopped = Matrix with chopped signal. Last dimension is segments. Only full segments returned.
% -------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------


%% Parsing input
defaultSegmentLength = 100; % Segment length [s]
defaultFs = 5.12; % Sampling frequency [Hz]
defaultOverlap = 50; % Overlap [%]

p = inputParser;
validPercentage = @(x) isnumeric(x) && isscalar(x) && (x < 100);
addRequired(p,'Signal', @validSignal);
addParameter(p,'SegmentLength',defaultSegmentLength,@isnumeric);
addParameter(p,'Fs',defaultFs, @isnumeric);
addParameter(p,'Overlap',defaultOverlap, validPercentage);
parse(p,signal,varargin{:});

p.Results; % diagnostic

%% Lengths and steps
segl=round(p.Results.SegmentLength*p.Results.Fs); % Number of points in one segment
dn=round((100-p.Results.Overlap)/100*p.Results.SegmentLength*p.Results.Fs); % Step for starting point
if dn<eps
    error('Overlap rounds to 100%');
end
N=size(p.Results.Signal,1); % Number of points in time dimension
nts=size(p.Results.Signal,2);
nsegments=floor((N-segl)/dn)+1;

%% Do the actual chop
n0=1; % Start point for segment
n1=n0+segl-1; % End point of segment

signal_chopped=zeros(segl,nts,nsegments);

ct=1; % Counter for chopped parts
while n1<=N
    signal_chopped(1:segl,:,ct)=signal(n0:n1,:);
    n0=n0+dn;
    n1=n1+dn;
    ct=ct+1;
end

signal_chopped=squeeze(signal_chopped);

end

function TF=validSignal(x)
    TF=false;
    if ~(ismatrix(x) && isnumeric(x))
        error('First input have to be a matrix.');
    else
        TF=true;
    end
end
