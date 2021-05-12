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

fn=fieldnames(wr);

for n=1:length(fn)
   p=fn{n};
   wr.(p)=wr.(p)(wr.r);
   lp.(p)=lp.(p)(lp.r); 
   rhs=wr.hs>0.25;
   if ~strcmp('time',p) & ~strcmp('r',p)
    bias.(p)=mean(lp.(p)(rhs)-wr.(p)(rhs));
    rmse.(p)=sqrt(mean((lp.(p)(rhs)-wr.(p)(rhs)).^2));
    si.(p)=rmse.(p)/mean(wr.(p)(rhs))*100;
    cc.(p)=corrcoef(lp.(p)(rhs),wr.(p)(rhs)); cc.(p)=cc.(p)(1,2);
    k.(p)=lp.(p)(rhs)\wr.(p)(rhs);
   end
end


figure
subplot 221
scatter(wr.hs,lp.hs)
xlabel('Waverider H_s (m)');
ylabel('LainePoiss H_s (m)')
p='hs';
title(sprintf('Bias=%.2f, RMSD=%.2f, SI=%.0f, corr=%.2f, K=%.2f',bias.(p),rmse.(p),si.(p),cc.(p),k.(p)));
ylim([0 2]);

hold on
plot([0 2], [0 2],'k');
subplot 222
scatter(wr.tm(rhs),lp.tm(rhs),2,wr.hs(rhs))
colorbar
hold on
plot([2 5], [2 5],'k');
title(loc);
p='tm';
xlabel('Waverider T_{m01} (s)');
ylabel('LainePoiss T_{m01} (s)')
title(sprintf('Bias=%.2f, RMSD=%.2f, SI=%.0f, corr=%.2f, K=%.2f',bias.(p),rmse.(p),si.(p),cc.(p),k.(p)));

subplot 223
scatter(wr.te(rhs),lp.te(rhs),2,wr.hs(rhs))
colorbar
hold on
plot([2 6], [2 6],'k');
title(loc);
p='te';
xlabel('Waverider T_{m-10} (s)');
ylabel('LainePoiss T_{m-10} (s)')
title(sprintf('Bias=%.2f, RMSD=%.2f, SI=%.0f, corr=%.2f, K=%.2f',bias.(p),rmse.(p),si.(p),cc.(p),k.(p)));

subplot 224
scatter(wr.tp(rhs),lp.tp(rhs),2,wr.hs(rhs))
colorbar
hold on
p='tp';
plot([2 8], [2 8],'k');
xlabel('Waverider T_{p} (s)');
ylabel('LainePoiss T_{p} (s)')
title(sprintf('Bias=%.2f, RMSD=%.2f, SI=%.0f, corr=%.2f, K=%.2f',bias.(p),rmse.(p),si.(p),cc.(p),k.(p)));



return
