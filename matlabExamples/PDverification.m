clc;clear all;close all;
data{1} = importfile('P steps.csv');
data{2} = importfile('D steps.csv');

%%
for i = 1:2
figure(i);clf;hold on;grid on;
subplotsCount = 4;
startsample = 200;
endsample = 1200;
time = data{i}.timeStamp(startsample:endsample) /1000;
pos = data{i}.wecPos(startsample:endsample);
vel = data{i}.wecVel(startsample:endsample);
kp = data{i}.UIWeckP(startsample:endsample);
kd = data{i}.UIWeckD(startsample:endsample);
torque = data{i}.wecTau(startsample:endsample);
torquefiltered = lowpass(torque, 10, 32); %data, passband, sample rate
expectedtorque = kp.*pos - kd.*vel;
ax(1) = subplot(subplotsCount,1,1);
xlabel('Time(s)')
yyaxis left
plot(time,pos);
ylabel('Position(m)')
yyaxis right
plot(time,vel);
ylabel('Velocity(m/s)')

ax(2) = subplot(subplotsCount,1,2);
xlabel('Time(s)')
yyaxis left
plot(time,kp,'.');
ylabel('kP')
yyaxis right
plot(time,kd,'.');
ylabel('kD')

ax(3) = subplot(subplotsCount,1,3);
xlabel('Time(s)')
%yyaxis left
plot(time,torque);
ylabel('Torque(Nm) = A * Nm/A')
%yyaxis right
%ylabel('Expected Torque(Nm)')

ax(4) = subplot(subplotsCount,1,4);
yyaxis left
xlabel('Time(s)')
plot(time, 100*abs(expectedtorque - torque)/abs(expectedtorque), 'LineWidth', 0.5, 'Marker', 'none', 'LineStyle','-')
ylabel('Torque Error(%)')
yyaxis right
plot(time, 100*abs(expectedtorque - torquefiltered)/abs(expectedtorque), 'LineWidth', 0.5, 'Marker', 'none', 'LineStyle','-')
ylabel('Torque Error Filtered(%)')

linkaxes(ax, 'x');
%legend({'Position','Velocity','Torque','kP', 'kD'},'location', 'southeast')
end

%%

figure
plot(data{1}.wecTau)


%%

rr = find(abs(data{1}.wecTau) > 1e-4);
qq = find(abs(data{1}.wecTau) <= 1e-4);
% rr = 683:1438;

tau_mc = data{1}.wecTau;
tau_fb = data{1}.wecPos.*data{1}.UIWeckP + data{1}.wecVel.*data{1}.UIWeckD;

[p,S] = polyfit(tau_fb(rr), tau_mc(rr), 1);
xx = linspace(min(tau_fb(rr)),max(tau_fb(rr)),100);
[yy,yyd] = polyval(p,xx,S);

f1 = figure;
grid on
hold on
scatter(tau_fb(rr), tau_mc(rr))
plot(xx,yy,'r--')
plot(xx,yy+2*yyd,'m--',xx,yy-2*yyd,'m--')
xlabel('Commanded torque [Nm]','interpreter','latex')
ylabel('Actual torque [Nm]','interpreter','latex')
legend('Data',...
    sprintf('Linear reg. ($y=%.2fx + %.2f$, $r^2$: %.2f, MAE: %.0e)',p(1),p(2),S.rsquared,mean(abs(tau_err(rr)))),...
    '95\% prediction interval',...
    'interpreter','latex')

exportgraphics(f1,'PDverification.pdf','ContentType','vector')

%%
clc
tau_err = tau_fb - tau_mc;
rms(tau_err(rr))
rms(tau_fb(rr))

rms(tau_err(qq))
rms(tau_fb(qq))

T = table([rms(tau_fb(qq));rms(tau_fb(rr))],[rms(tau_err(qq));rms(tau_err(rr))],...
    'VariableNames',{'FB','Error'},'RowNames',{'Zero command','Non-zero command'})

%%

figure
histogram(tau_err)