function [block, block_time]=lpp_get_block(signal,signal_time,time0,query_time,block_length)
%[block, blocktime]=lpp_get_block(filename,variable,time,blocklength): Get blocks of certain length from netcdf-file
%Example: [block, blocktime]=lpp_get_block('AccZ_Suomenlinna2020.nc','AccZ',time,30)
% ---------------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   signal = Long time series from where the blocks are taken
%   signal_time = Time vector for signal, given as ms since time0
%   time0 = Start time of deployment
%   query_time = Wanted starting times for blocks (datetime vector)
%   block_length = desired blocklength (in points)
% ---------------------------------------------------------------------------------------------------------
% Output:
%  block = Block of data
%  block_time = Buoy time stamps for data
% ---------------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% ---------------------------------------------------------------------------------------------------------

%% Parsing input
p = inputParser;
addRequired(p,'Signal');
addRequired(p,'Signal_time', @isvector);
addRequired(p,'Time0', @isdatetime);
addRequired(p,'Query_time', @(x) (isdatetime(x) && isvector(x)));
addRequired(p,'Blocklength', @isscalar);
%addParameter(p,'F0',defaultF0, @isnumeric);
parse(p,signal,signal_time,time0,query_time,block_length);
ct=1;
dt=min(diff(signal_time)); % Time resolution in the time series
for n=1:length(query_time)
    query_time_rel=seconds(query_time(n)-time0)*1000; % Relative query times in milliseconds

    ind0=find(query_time_rel<=signal_time,1,'first');
    %ind1=find(query_time_rel+block_length*1000>signal_time,1,'last');
    ind1=ind0+block_length-1;
    %if ~(isempty(ind0) || isempty(ind1) || abs(query_time_rel-signal_time(ind0))>dt || abs(query_time_rel+block_length*1000-signal_time(ind1))>dt)
    if ~(isempty(ind0) || ind1>size(signal,1))
        try 
            block(:,ct)=signal(ind0:ind1);
            block_time(:,ct)=signal_time(ind0:ind1);
            ct=ct+1;
        catch
            keyboard
        end
    end
    
end
if ct==1
    block=[];
    block_time=[];
end


end

