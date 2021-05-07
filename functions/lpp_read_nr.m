function nr = lpp_read_nr(filename,varargin)
%nr = lpp_read_nr: Reads LainePoiss NR-files (raw data).
%Example: nr = lpp_read_nr('raw_2020_09_24_11_48_NR0124.txt')
% -------------------------------------------------------------------------------------------------
% Input:
% [Required]
%   filename = The NR-file (string)
% [Optional]
%   checkgaps = Check for gaps and interpolate under 200 ms gaps (default = true)
% -------------------------------------------------------------------------------------------------
% Output:
%   nr = Struct with nr.header and nr.data. Missing values in data marked with 0. Gaps less than 200 ms interpolated.
% -------------------------------------------------------------------------------------------------
% This function is a part of the LainePoiss Processing package.
% Jan-Victor Björkqvist & Victor Alari (2021)
% -------------------------------------------------------------------------------------------------

%% Parsing input
defaultCheckGaps = true;

p = inputParser;
addRequired(p,'Filename', @ischar);
addParameter(p,'CheckGaps',defaultCheckGaps,@islogical);
parse(p,filename,varargin{:});

%% Read in header
fid = fopen(p.Results.Filename);
headerline1 = fgetl(fid);

% Get start time of deployment
numbers=regexp(headerline1,'\d*','match');
nr.header.time0=datetime(strcat(numbers{1:6}),'InputFormat','yyyyMMddHHmmSS');

nr.header.bat_percent=str2num(numbers{7});
nr.header.bat_hour=str2num(numbers{8});
nr.header.bat_voltage=str2num(strcat(numbers{9},'.', numbers{10}));
nr.header.lat=str2num(strcat(numbers{11},'.', numbers{12}));
nr.header.lon=str2num(strcat(numbers{13},'.', numbers{14}));

%% Create fields for data-struct using second header line
headerline2 = fgetl(fid);
str=regexprep(headerline2, '\s+', ''); % remove whitespaces
str=regexprep(str, '\(.*?\)', ''); % Remove brackets and units inside them
Fn=strsplit(str,',');

fclose(fid);

data=csvread(p.Results.Filename,2,0);

for n=1:length(Fn)
   pp=Fn{n};
   nr.data.(pp)=data(:,n);
end

%disp(max(diff(nr.data.Time)))
if p.Results.CheckGaps
    for n=1:length(Fn)
       pp=Fn{n};
       if ~strcmp('Time',pp)
           [nr.data.(pp), newtime] = lpp_check_for_gaps(nr.data.(pp),nr.data.Time,200);
       end
    end
    nr.data.Time=newtime;
end 
%     
%     dt=min(diff(nr.data.Time));
%     if max(diff(nr.data.Time))>dt
%         if max(diff(nr.data.Time))<=200
%             newtime=int64(nr.data.Time(1):dt:nr.data.Time(end));
%             r=ismember(newtime,int64(nr.data.Time));
%             N=length(nr.data.Time);
% 
%             for n=1:length(Fn)
%                pp=Fn{n};
%                if ~strcmp('Time',pp)
%                    junk=NaN*ones(length(newtime),1);
%                    junk(r)=nr.data.(pp);
%                    junk=interpNaN(junk);
%                    nr.data.(pp)=junk(1:N);
%                    clear junk
%                end
%             end
%             nr.data.Time=double(newtime(1:N));
%             %any(isnan(nr.data.AccZ))
%         else
%             %warning('%.0f',max(diff(nr.data.Time)));
%             for n=1:length(Fn)
%                pp=Fn{n};
%                if ~strcmp('Time',pp)
%                     nr.data.(pp)=nr.data.(pp)*NaN;
%                end
%             end
%         end
%     end


end

function y=interpNaN(y,m,l)
% function y=interpNaN(y,m,l)
%      
% Interpoloi puuttuvat arvot m asteen polynomilla
% Lineaarinen interpolaatio k�ytt�� nopeaa interpolointa

if nargin==1, m=1; end
if nargin==2, l=5; end

X = diff(isnan(y));
a=find(X>0);
b=find(X<0);

if a(1) > b(1), b(1)=[]; end
if b(end) < a(end), a(end)=[]; end
N=length(a);

if m==1
    for j=1:N
       i=a(j); k=b(j)+1;
       y(i+1:k-1)=interp1q([i;k],[y(i);y(k)],[i+1:k-1]')';
    end
else    
    for j=1:N
      i=a(j); k=b(j)+1;
      P=polyfit([i-l:i,k:k+l]',[y(i-l:i),y(k:k+l)]',m);
      y(i+1:k-1)=polyval(P,[i+1:k-1]);
    end  
end    
end

