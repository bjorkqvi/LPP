function [checked, checked_time] = lpp_check_for_gaps(signal,time,maxgap)
%[checked, checked_time] = lpp_check_for_gaps(signal,time,maxgap)
%Example: [checked, checked_time] = lpp_check_for_gaps(signal,time,200)
% -------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal = The signal (matrix) to possibly be interpolated.
%   time = Matrix with values in milliseconds.
% [Optional]
%   maxgap = Maximum gap to be interpolated. If given a time series is returned (NaN is gap is too large).
%            If omitted, then a logical is returned (true if no gaps present).
% -------------------------------------------------------------------------------------------------
% Output:
%   checked = New time series without gaps. NaN if gap too large. Logical is no max gap is provided.
%   checked_time = Time vecotor [ms] for the new time series. Not provided if maxgap in not defined.
% -------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------

%% Parsing input

p = inputParser;
addRequired(p,'Signal', @isnumeric);
addRequired(p,'Time', @isnumeric);

%addParameter(p,'Maxgap', @isnumeric);
parse(p,signal,time);

samplingtime=min(diff(p.Results.Time(:,1))); % Sampling time of signal 


for n=1:size(p.Results.Signal,2)
    if nargin==2
        checked(n)=max(diff(p.Results.Time(:,n)))<=samplingtime;
        checked_time=[];
    else
        if max(diff(p.Results.Time(:,n)))>samplingtime
            if max(diff(p.Results.Time(:,n)))<=maxgap
               newtime=int64(p.Results.Time(:,1):samplingtime:p.Results.Time(:,end));
               r=ismember(newtime,int64(p.Results.Time(:,n)));
               N=size(p.Results.Signal,1);

               junk=NaN*ones(length(newtime),1);
               junk(r)=p.Results.Signal(:,n);
               junk=interpNaN(junk);
               checked(:,n)=junk(1:N);

               checked_time(:,n)=double(newtime(1:N));
            else % Too large gap to interpolate
                checked(:,n)=p.Results.Signal(:,n)*NaN;
                checked_time(:,n)=p.Results.Time(:,n)*NaN;
            end
        else % Return original signal if no gaps are found
            checked(:,n)=p.Results.Signal(:,n);
            checked_time(:,n)=p.Results.Time(:,n);
        end
    end
end


end

