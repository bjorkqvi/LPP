function spec = lpp_spectrum_welch(signal_chopped,varargin)
%spec = lpp_spectrum_welch: Calculates the power spectrum using the Welch method.
%Example: spec = lpp_spectrum_welch(signal_chopped,'fs',5.12,'window','hann')
% -------------------------------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal_chopped = Matrix with chopped signal (t x k) or (t x n x k), with t=time and k=segments.
% [Optional]
%   'fs': Sampling frequency [Hz] (default = 5.12).
%   'window': Window for tapering. 'hann' or 'blackhar' (default = 'hann').
% -------------------------------------------------------------------------------------------------------------------------------
% Output:
%   spec = A struct containing spec.f (m x 1 linear frequency vector, Hz) and spec.psd (m x n spectral density matrix, unit^2/Hz)
% -------------------------------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------------------------------

%% Parsing input
defaultFs = 5.12; % Sampling frequency [Hz]
defaultWindow = 'hann'; % Window tapering
expectedWindows = {'hann','blackhar'};

p = inputParser;
addRequired(p,'Signal_Chopped', @validSignal);
addParameter(p,'Fs',defaultFs, @isnumeric);
addParameter(p,'Window',defaultWindow, @(x) any(validatestring(x,expectedWindows)));
parse(p,signal_chopped,varargin{:});

% Get the number of blocks
if ismatrix(p.Results.Signal_Chopped)  % Only one time series
    Nchopped=size(p.Results.Signal_Chopped,2); 
    Nseries=1;
else % Several time series
    Nchopped=size(p.Results.Signal_Chopped,3); 
    Nseries=size(p.Results.Signal_Chopped,2); 
end

%% Define window
switch p.Results.Window
    case 'hann'
        w=hann(size(p.Results.Signal_Chopped,1));
    case 'blackhar'
        w=blackhar(size(p.Results.Signal_Chopped,1));
end

%% Loop through time series and blocks
for t=1:Nseries
    for k=1:Nchopped
        %% This block of code is taken and modified from Kimmo Kahma's spectr.m function
        % ------------------------------------------------------------------------------
        if Nseries==1
            x=p.Results.Signal_Chopped(:,k);
        else
            x=p.Results.Signal_Chopped(:,t,k);
        end
        
       
        Xx = fft(w.*detrend(x));
        Nfft = length(Xx); % Number of points in FFT
        maxb = fix(Nfft/2)+1;
        Xx(maxb+1:Nfft)=[];
        Xx(maxb) = Xx(maxb)/2;

        C = 2/(p.Results.Fs*norm(w)^2); % Scaling coefficient
        df = p.Results.Fs/Nfft;

        Pzz(:,k) = (abs(Xx).^2)*C;
        f=[0:maxb-1]'*df;
        % ------------------------------------------------------------------------------
    end
    
    % Average spectra from all the blocks
    spec.psd(:,t)=mean(Pzz,2);    
end

% Set frequency vector
spec.f=f;


end

function TF=validSignal(x)
    TF=false;
    if ~(isnumeric(x))
        error('First input have to be a numeric matrix.');
    elseif ~(length(size(x)) == 2 || length(size(x)) == 3)
        error('First input need to have 2 or 3 dimensions (time always first dimension and chopped index last dimension)');
    else
        TF=true;
    end
end

function w=hann(N)
    m = [0:N-1];
    w = 0.5*(1-cos(2*pi*m/N))';
end

function w=blackhar(N)
    %BLACKHAR   BLACKHAR(N) returns the N-point Blackman-Harris window.
    %K.Kahma 1989-07-20 Updated 2008-01-13
    m=(0:N-1)/(N-1);
    w = (.35875-.48829*cos(2*pi*m)+.14128*cos(4*pi*m)-0.01168*cos(6*pi*m))';
end

