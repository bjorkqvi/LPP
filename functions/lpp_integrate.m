function [elev,noiseNorm]=lpp_integrate(signal,fs,varargin)
%lpp_denoise: Integrate acceleration to get elevation 
%Example: elev = lpp_integrate(accFft,f,'denoise', false)
% ------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal = Input acceleration
%   fs = Sampling frequency [Hz]
% [Optional]
%  denoise: Denoise spectrum using low-frequency noise (default = true)
%  cutTransients: Cut 30 second from start and end of integrated time series (default = true)
% -------------------------------------------------------------------------------------------------------
% Output:
%   elev = Time-series of elevations.
%   noiseNorm = Normalized mean noise amplitude between fLow and fHigh
% -------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Victor Alari & Jan-Victor Björkqvist (2021)
% -------------------------------------------------------------------------------------------------------

%% Parsing input
defaultDenoise = true ;
defaultCutTransients= true;
p = inputParser;
validVector = @(x) isnumeric(x) && isvector(x) || ismatrix(x);
validScalar = @(x) isnumeric(x) && isscalar(x);
addRequired(p,'signal',validVector);
addRequired(p,'fs',validScalar);
addParameter(p,'denoise',defaultDenoise,@islogical);
addParameter(p,'cutTransients',defaultCutTransients,@islogical);
parse(p,signal,fs,varargin{:});
p.Results; % diagnostic

%% Integrate to get elevation
[Nfft,N]=size(p.Results.signal);

if rem(Nfft, 2) == 1
   %error('Input time-series is odd')
   signal=p.Results.signal(1:end-1,:);
   [Nfft,N]=size(signal);
else
    signal=p.Results.signal;
end

f=fs*(-Nfft/2:1:Nfft/2-1)'/Nfft; % FFT frequencies [Hz]
rf=lpp_response(f);
elev=zeros(Nfft,N);

for col=1:N
    accFft=fftshift(fft(detrend(signal(:,col)))) ; % Take the Fast Fourier Transfrom of signal

    if p.Results.denoise 
        [accFftDenoised,noiseNorm]=lpp_denoise(accFft,f);
        elevFft=accFftDenoised.*rf;
    else
        elevFft=accFft.*rf;
        noiseNorm=NaN;
    end

elev(:,col)=detrend(real(ifft(fftshift(elevFft))));
end

if p.Results.cutTransients 
    elev=detrend(elev(round(30*fs):end-round(30*fs),:)); % Cut 30 s from start and end
end

end
