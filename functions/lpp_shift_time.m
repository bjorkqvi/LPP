function time_shifted = lpp_shift_time(time,drift,direction)
%time_shifted = lpp_shift_time(time,drift,direction):
%Example: time_shifted = lpp_shift_time(time,60,'LPtoUTC')
% -------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   time = Datetime vector (time(1) is anchor point and is not changed).
%   drift = Drift of clock given as seconds/month (1 month = 365.25/12 days).
%   direction = 'UTCtoLP' or 'LPtoUTC' (case insensitive).
% -------------------------------------------------------------------------------------------------
% Output:
%   time_shifted = Shifted datetime vector, where time_shifted(1)=time(1).
% -------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------

%% Parsing input

p = inputParser;
addRequired(p,'Time', @(x) (isvector(x) && isdatetime(x)));
addRequired(p,'Drift', @isscalar);
addRequired(p,'Direction', @ischar);
parse(p,time,drift,direction);



dt=p.Results.Drift/(365.25/12*24*60*60); % Drift: second/month -> second/second
time_rel=seconds(p.Results.Time-p.Results.Time(1));
switch lower(p.Results.Direction)
    case 'lptoutc'
        time_shifted=time_rel-dt*time_rel;
        time_shifted=seconds(time_shifted)+p.Results.Time(1);
    case 'utctolp'
        time_shifted=time_rel/(1-dt);
        time_shifted=seconds(time_shifted)+p.Results.Time(1);
    otherwise
        error('Set direction to either ''LPtoUTC'' or ''UTCtoLP'' (case insensitive)');
end

end

