function [accFftDenoised,noiseNorm]=lpp_denoise(signalFft,f,varargin)
%lpp_denoise: Get rid of low frequency noise. 
%Example: [accFftDenoised,noiseNorm] = lpp_denoise(accFft,f,'fLow',0.01,'fHigh',1/30)
% ------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   accFft = Fft of acceleration
%   f = Frequency vector.
% [Optional]
%  fLow: Low freq of noise interval
%  fHigh = High freq of noise interval
% -------------------------------------------------------------------------------------------------------
% Output:
%   accFftDenoised = Denoised fft.
%   noiseNorm = Normalized mean noise amplitude between fLow and fHigh
% -------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------
%% Parsing input
defaultFLow = 1/100; % [Hz]
defaultFHigh = 1/30; % [Hz]

p = inputParser;
validVector = @(x) isnumeric(x) && isvector(x);
validScalar = @(x) isnumeric(x) && isscalar(x);
addRequired(p,'signalFft',validVector);
addRequired(p,'f',validVector);
addParameter(p,'fLow',defaultFLow,validScalar);
addParameter(p,'fHigh',defaultFHigh,validScalar);

parse(p,signalFft,f,varargin{:});
p.Results; % diagnostic

%% Denoise

k_noise=abs(f)<p.Results.fHigh & abs(f)>p.Results.fLow;
amp=abs(signalFft);
noise_amp=mean(amp(k_noise));
scale=(amp-noise_amp)./amp;
scale(scale<0)=0;
accFftDenoised=signalFft.*scale;

if nargout > 1
    Nfft=size(signalFft,1);
    amp_normalized=abs(signalFft./Nfft);
    noiseNorm=mean(amp_normalized(k_noise));
end


