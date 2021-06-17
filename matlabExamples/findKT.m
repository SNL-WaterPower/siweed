clc;clear all;close all;
data{1} = importfile('C:\Users\sjspenc\Documents\MATLAB\new_Tau_tests\6-15-2021_16-47-1.csv');
data{2} = importfile('C:\Users\sjspenc\Documents\MATLAB\new_Tau_tests\6-15-2021_16-55-16.csv');
data{3} = importfile('C:\Users\sjspenc\Documents\MATLAB\new_Tau_tests\6-15-2021_17-0-32.csv');

%%
for i = 1:3
figure(i);clf;hold on;grid on;
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
legend({'data','fit1','selected','fit2'},'location','southeast')

figure(i+3);clf;hold on;grid on;
plot(I,tau-polyval(p1,I),'.')
plot(I(abs(I)<0.3),tau(abs(I)<0.3)-polyval(p2,I(abs(I)<0.3)),'.')
legend({'tau_{err}','tau_{err_2}'},'location','northwest')
xlabel('current (A)')
ylabel('torque error (Nm)')
    
tau_error = tau(abs(I)<0.3)-polyval(p2,I(abs(I)<0.3));
mean(tau_error(tau_error>0))
mean(tau_error(tau_error<0))
mean(abs(tau_error))
end