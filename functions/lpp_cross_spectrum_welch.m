function spec = lpp_cross_spectrum_welch(signal_chopped1,signal_chopped2,signal_chopped3,varargin)
%spec = lpp_spectrum_welch: Calculates the power spectrum using the Welch method.
%Example: spec = lpp_cross_spectrum_welch(signal_chopped,'fs',5.12,'window','hann')
% -------------------------------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal_chopped1 = Matrix with chopped signal (t x k) or (t x n x k), with t=time and k=segments.
%   signal_chopped2 = Matrix with chopped signal (t x k) or (t x n x k), with t=time and k=segments.
%   signal_chopped3 = Matrix with chopped signal (t x k) or (t x n x k), with t=time and k=segments.
%   NB NB! By default the program assumes that the signal inputs are in the
%   order x, y and z displacement.
% [Optional]
%   'fs': Sampling frequency [Hz] (default = 5.12).
%   'window': Window for tapering. 'hann' or 'blackhar' (default = 'hann').
% -------------------------------------------------------------------------------------------------------------------------------
% Output:
%   spec = A struct containing spec.f (m x 1 linear frequency vector, Hz) and spec.auto (m x 3 spectral density matrix, unit^2/Hz)
%          and spec.a1 spec.b1 containing fourier cofficients per (m x 1)
%          and spec.Qzx spec.Qzy (m x 1 cross spectral density unit^2/Hz)
% -------------------------------------------------------------------------------------------------------------------------------
% Reference
% https://www.datawell.nl/Portals/0/Documents/Manuals/datawell_manual_dwr4_2019-01-01.pdf
% equations 7.12 7.17 7.18 for cross-spectra and coefficients a1 and b1

% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------------------------------------

%% Parsing input
defaultFs = 5.12; % Sampling frequency [Hz]
defaultWindow = 'hann'; % Window tapering
expectedWindows = {'hann','blackhar'};

p = inputParser;
addRequired(p,'Signal_Chopped1', @validSignal);
addRequired(p,'Signal_Chopped2', @validSignal);
addRequired(p,'Signal_Chopped3', @validSignal);
addParameter(p,'Fs',defaultFs, @isnumeric);
addParameter(p,'Window',defaultWindow, @(x) any(validatestring(x,expectedWindows)));
parse(p,signal_chopped1,signal_chopped2,signal_chopped3,varargin{:});


% Get the number of blocks
if ismatrix(p.Results.Signal_Chopped1)  % Only one time series
    Nchopped=size(p.Results.Signal_Chopped1,2); 
    Nseries=1;
else % Several time series
    Nchopped=size(p.Results.Signal_Chopped1,3); 
    Nseries=size(p.Results.Signal_Chopped1,2); 
end

%% Define window
switch p.Results.Window
    case 'hann'
        w=hann(size(p.Results.Signal_Chopped1,1));
    case 'blackhar'
        w=blackhar(size(p.Results.Signal_Chopped1,1));
end

%% Loop through time series and blocks
for t=1:Nseries
    for k=1:Nchopped
        %% This block of code is taken and modified from Kimmo Kahma's spectr.m function
        % ------------------------------------------------------------------------------
        if Nseries==1
            x=squeeze(p.Results.Signal_Chopped1(:,k));
            y=squeeze(p.Results.Signal_Chopped2(:,k));
            z=squeeze(p.Results.Signal_Chopped3(:,k));
        else
            x=p.Results.Signal_Chopped1(:,t,k);
            y=p.Results.Signal_Chopped2(:,t,k);
            z=p.Results.Signal_Chopped3(:,t,k);
        end
       
        Xx = fft(w.*detrend(x));
        Nfft = length(Xx); % Number of points in FFT
        maxb = fix(Nfft/2)+1;
        Xx(maxb+1:Nfft,:)=[];
        Xx(maxb,:) = Xx(maxb,:)/2;

        Yy = fft(w.*detrend(y));
        Yy(maxb+1:Nfft,:)=[];
        Yy(maxb,:) = Yy(maxb,:)/2;
        
        Zz = fft(w.*detrend(z));
        Zz(maxb+1:Nfft,:)=[];
        Zz(maxb,:) = Zz(maxb,:)/2;
        
        C = 2/(p.Results.Fs*norm(w(:,1))^2); % Scaling coefficient
        df = p.Results.Fs/Nfft;

        Pxx(:,k) = (abs(Xx).^2)*C;
        Pyy(:,k) = (abs(Yy).^2)*C;
        Pzz(:,k) = (abs(Zz).^2)*C;
        f=[0:maxb-1]'*df;
        
        Qzx(:,k)=C*(imag(Zz).*real(Xx)-imag(Xx).*real(Zz));
        Qzy(:,k)=C*(imag(Zz).*real(Yy)-imag(Yy).*real(Zz));
        
      %  a1(:,k)=Qzx(:,k)./(sqrt(Pauto(:,3,k).*(Pauto(:,1,k)+Pauto(:,2,k))));
      %  b1(:,k)=Qzy(:,k)./(sqrt(Pauto(:,3,k).*(Pauto(:,1,k)+Pauto(:,2,k))));
        f=[0:maxb-1]'*df;
        % ------------------------------------------------------------------------------
    end
    
    % Average spectra from all the blocks
    spec.Xx(:,t)=mean(Pxx,2);  
    spec.Yy(:,t)=mean(Pyy,2); 
    spec.Zz(:,t)=mean(Pzz,2); 
    spec.Qzx(:,t)=mean(Qzx,2); 
    spec.Qzy(:,t)=mean(Qzy,2); 
    %spec.a1=mean(a1,2);
    %spec.ab=mean(ab,2);
    spec.a1(:,t)=spec.Qzx(:,t)./(sqrt(spec.Zz(:,t).*(spec.Yy(:,t)+spec.Xx(:,t))));
    spec.b1(:,t)=spec.Qzy(:,t)./(sqrt(spec.Zz(:,t).*(spec.Yy(:,t)+spec.Xx(:,t))));
    
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

