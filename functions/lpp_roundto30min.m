function rounded_time = lpp_roundto30min(time)
%function rounded_time = lpp_roundto30min(time)

%first round of seconds
r1=second(time)<30;
r2=second(time) >= 30;

time(r1)=time(r1)-seconds(second(time(r1)));
time(r2)=time(r2)+seconds(60)-seconds(second(time(r2)));

% Now round of minutes

r1=minute(time)<15;
r2=minute(time) >= 15 & minute(time) < 30;
r3=minute(time) > 30 & minute(time) < 45;
r4=minute(time)>=45;

rounded_time=time;
rounded_time(r1)=time(r1)-minutes(minute(time(r1)));
rounded_time(r2)=time(r2)+minutes(30)-minutes(minute(time(r2)));
rounded_time(r3)=time(r3)+minutes(30)-minutes(minute(time(r3)));
rounded_time(r4)=time(r4)+minutes(60)-minutes(minute(time(r4)));


end

