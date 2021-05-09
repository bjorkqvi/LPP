clear
close all

addpath('../LPP/functions/')

%% Location and deployment settings
loc='Suomenlinna';
yyyy=2020;

system(sprintf('ls %s/WR/raw/*.raw > %s/WR/raw/raw.list',loc,loc));
filelist.wr=importdata(sprintf('%s/WR/raw/raw.list',loc));

ct=1;
expr='[0-9]{4}';

n0=1;
%n1=10;
n1=length(filelist.wr);

up=zeros(2304,n1-n0+1);
east=zeros(2304,n1-n0+1);
north=zeros(2304,n1-n0+1);

for n=n0:n1
    disp(ct)
    fn=filelist.wr{n};
    ind=regexp(fn,expr);
    numbers=regexp(fn(ind:ind+15),'\d*','match');   
    time0(ct)=datetime(strcat(numbers{:}),'InputFormat','yyyyMMddHHmm');
    
    raw=load(fn);
    up(:,ct)=raw(:,2)*0.01;
    north(:,ct)=raw(:,3)*0.01;
    east(:,ct)=-raw(:,4)*0.01;
    
    ct=ct+1;

end
Fn=sprintf('netcdf/WR_up_30min_%s%.0f.nc',loc,yyyy);
lpp_write_netcdf_raw(Fn,up,time0,'name',loc,'depth',22,'fs',1.28,'longitude',24+58.35/60,'latitude',60+07.40/60,'source','Waverider Mk-III');

Fn=sprintf('netcdf/WR_east_30min_%s%.0f.nc',loc,yyyy);
lpp_write_netcdf_raw(Fn,east,time0,'name',loc,'depth',22,'fs',1.28,'longitude',24+58.35/60,'latitude',60+07.40/60,'source','Waverider Mk-III');

Fn=sprintf('netcdf/WR_north_30min_%s%.0f.nc',loc,yyyy);
lpp_write_netcdf_raw(Fn,north,time0,'name',loc,'depth',22,'fs',1.28,'longitude',24+58.35/60,'latitude',60+07.40/60,'source','Waverider Mk-III');

