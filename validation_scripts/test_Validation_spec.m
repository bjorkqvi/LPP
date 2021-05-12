clear
close all

loc='Suomenlinna';
yyyy=2020;
run_index='depl_04_01';

Fn.wr=sprintf('netcdf/WR_param_30min_%s%.0f.nc',loc,yyyy); 
Fn.lp=sprintf('netcdf/param_30min_renorm_%s%.0f_%s.nc',loc,yyyy,run_index); 

wr.time=datetime(ncread(Fn.wr,'time'),'convertfrom','posixtime');
wr.hs=ncread(Fn.wr,'hs');
wr.tm=ncread(Fn.wr,'tm01');
wr.te=ncread(Fn.wr,'tm_10');
wr.tp=ncread(Fn.wr,'tp');

lp.time=datetime(ncread(Fn.lp,'time'),'convertfrom','posixtime');
lp.tm=ncread(Fn.lp,'tm01');
lp.te=ncread(Fn.lp,'tm_10');
lp.hs=ncread(Fn.lp,'hs');
lp.tp=ncread(Fn.lp,'tp');
plot(wr.time,wr.hs,'k');hold on
plot(lp.time,lp.hs,'r');
xlim([lp.time(1) lp.time(end)]);


[~,wr.r,lp.r]=joindate(wr.time,wr.hs,lp.time,lp.hs);

% fn=fieldnames(wr);
% 
% for n=1:length(fn)
%    p=fn{n};
%    wr.(p)=wr.(p)(wr.r);
%    lp.(p)=lp.(p)(lp.r); 
% end
% 
% r=wr.hs>0.25;
% figure
% subplot 221
% scatter(wr.hs,lp.hs)
% ylim([0 2]);
% 
% hold on
% plot([0 2], [0 2],'k');
% subplot 222
% scatter(wr.tm(r),lp.tm(r),2,wr.hs(r))
% colorbar
% hold on
% plot([2 5], [2 5],'k');
% 
% subplot 223
% scatter(wr.te(r),lp.te(r),2,wr.hs(r))
% colorbar
% hold on
% plot([2 6], [2 6],'k');
% 
% subplot 224
% scatter(wr.tp(r),lp.tp(r),2,wr.hs(r))
% colorbar
% hold on
% plot([2 8], [2 8],'k');



Fn.wr=sprintf('netcdf/WR_spec_30min_%s%.0f.nc',loc,yyyy); 
Fn.lp=sprintf('netcdf/spec_30min_renorm_%s%.0f_%s.nc',loc,yyyy,run_index); 
%Fn.lp0=sprintf('netcdf/spec_30min_renorm_%s%.0f_%s.nc',loc,yyyy,run_index); 
wr.spec=ncread(Fn.wr,'spec');
wr.f=ncread(Fn.wr,'f');

lp.spec=ncread(Fn.lp,'spec');
%lp.spec0=ncread(Fn.lp0,'spec');
lp.f=ncread(Fn.lp,'f');

lp.Sm=mean(lp.spec(:,lp.r),2);
%lp.Sm0=mean(lp.spec0(:,lp.r),2);
wr.Sm=mean(wr.spec(:,wr.r),2);

figure
subplot 121
plot(wr.f,mean(wr.spec(:,wr.r),2),'k'); hold on
%plot(lp.f,mean(lp.spec0(:,lp.r),2),'r--'); hold on
plot(lp.f,mean(lp.spec(:,lp.r),2),'r'); hold on
xlim([0 0.6])

%d=(sum(lp.Sm0)-sum(lp.Sm)-2*1.4*10^-6);

%plot(lp.f,lp.Sm+d*lp.Sm/sum(lp.Sm),'b'); hold on
subplot 122
loglog(wr.f,mean(wr.spec(:,wr.r),2),'k'); hold on
%loglog(lp.f,mean(lp.spec(:,lp.r),2),'r'); hold on
loglog(lp.f,mean(lp.spec(:,lp.r),2),'r--'); hold on
%loglog(lp.f,lp.Sm+d*lp.Sm/sum(lp.Sm),'b'); hold on
ylim([10^-4 0.2])
% bias=mean((lp.hs(lp.r)-wr.hs(wr.r)));
% rmse=sqrt(mean((lp.hs(lp.r)-wr.hs(wr.r)).^2));
% si=rmse/mean(wr.hs(wr.r))*100;
% cc=corrcoef(lp.hs(lp.r),wr.hs(wr.r));
