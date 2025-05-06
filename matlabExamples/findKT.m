clc;clear all;close all;
data{1} = importfile('6-15-2021_16-47-1.csv');
data{2} = importfile('6-15-2021_16-55-16.csv');
data{3} = importfile('6-15-2021_17-0-32.csv');

%%
for i = 1:3
f1(i) = figure(i);
clf
hold on
grid on;
Kt0 = 0.0078;
I = data{i}.wecTau/Kt0;
x = data{i}.wecPos;
R_buoy = 0.06;
A = pi*R_buoy^2;
rhoH2O = 1000;
g = 9.81;
R_pinion = 0.25*.0254;
F = rhoH2O*g*A*x;
tau = F*R_pinion;
plot(I,tau,'.')
p1 = polyfit(I,tau,1);
plot(sort(I),polyval(p1,sort(I)),'linewidth',2)
plot(I(abs(I)<0.3),tau(abs(I)<0.3),'.')
p2 = polyfit(I(abs(I)<0.3),tau(abs(I)<0.3),1);
p1*1000
p2*1000
plot(sort(I),polyval(p2,sort(I)),'--','linewidth',2)
legend({'Data','Linear trend (all data)','Selected data',...
    'Linear trend (selected data)'},'location','southeast','Interpreter','latex')
xlabel('Current, $I$ [A]','Interpreter','latex')
ylabel('Torque, $\tau$ [Nm]','Interpreter','latex')
exportgraphics(f1(i),sprintf('findKT_%i.pdf',i),'ContentType','vector')


f2(i) = figure(i+3);
clf
hold on
grid on;
plot(I,tau-polyval(p1,I),'.')
plot(I(abs(I)<0.3),tau(abs(I)<0.3)-polyval(p2,I(abs(I)<0.3)),'.')
legend({'All data','Data w. $I<0.3$A'},'location','northwest','Interpreter','latex')
xlabel('Current, $I$ [A]','Interpreter','latex')
ylabel('Torque error [Nm]','Interpreter','latex')
exportgraphics(f2(i),sprintf('torque_error_%i.pdf',i),'ContentType','vector')

tau_error = tau(abs(I)<0.3)-polyval(p2,I(abs(I)<0.3));
mean(tau_error(tau_error>0))
mean(tau_error(tau_error<0))
mean(abs(tau_error))
end;