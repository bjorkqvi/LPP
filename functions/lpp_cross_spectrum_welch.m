function spec = lpp_cross_spectrum_welch(signal_chopped,varargin)
%spec = lpp_spectrum_welch: Calculates the power spectrum using the Welch method.
%Example: spec = lpp_cross_spectrum_welch(signal_chopped,'fs',5.12,'window','hann')
% -------------------------------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal_chopped = Matrix with chopped signal (t x 3 x k), with t=time ,3-x y z displacements, k=segments.
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
        w=repmat(hann(size(p.Results.Signal_Chopped,1)),1,3);
    case 'blackhar'
        w=repmat(blackhar(size(p.Results.Signal_Chopped,1)),1,3);
end

%% Loop through time series and blocks
%for t=1:Nseries
    for k=1:Nchopped
        %% This block of code is taken and modified from Kimmo Kahma's spectr.m function
        % ------------------------------------------------------------------------------
      %  if Nseries==1
            x=squeeze(p.Results.Signal_Chopped(:,:,k));
      %  else
          %  x=p.Results.Signal_Chopped(:,t,k);
      %  end
       
        Xx = fft(w.*detrend(x));
        Nfft = length(Xx); % Number of points in FFT
        maxb = fix(Nfft/2)+1;
        Xx(maxb+1:Nfft,:)=[];
        Xx(maxb,:) = Xx(maxb,:)/2;

        C = 2/(p.Results.Fs*norm(w(:,1))^2); % Scaling coefficient
        %dt=1/p.Results.Fs;
       % C = dt/(pi*norm(w(:,1))^2);
        df = p.Results.Fs/Nfft;

        Pauto(:,:,k) = (abs(Xx).^2)*C;
        
        Qzx(:,k)=C*(imag(Xx(:,3)).*real(Xx(:,1))-imag(Xx(:,1)).*real(Xx(:,3)));
        Qzy(:,k)=C*(imag(Xx(:,3)).*real(Xx(:,2))-imag(Xx(:,2)).*real(Xx(:,3)));
        
      %  a1(:,k)=Qzx(:,k)./(sqrt(Pauto(:,3,k).*(Pauto(:,1,k)+Pauto(:,2,k))));
      %  b1(:,k)=Qzy(:,k)./(sqrt(Pauto(:,3,k).*(Pauto(:,1,k)+Pauto(:,2,k))));
        f=[0:maxb-1]'*df;
        % ------------------------------------------------------------------------------
    end
    
    % Average spectra from all the blocks
    spec.auto=mean(Pauto,3);  
    spec.Qzx=mean(Qzx,2); 
    spec.Qzy=mean(Qzy,2); 
    %spec.a1=mean(a1,2);
    %spec.ab=mean(ab,2);
    spec.a1=spec.Qzx./(sqrt(spec.auto(:,3).*(spec.auto(:,2)+spec.auto(:,1))));
    spec.b1=spec.Qzy./(sqrt(spec.auto(:,3).*(spec.auto(:,2)+spec.auto(:,1))));
    
%end

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

