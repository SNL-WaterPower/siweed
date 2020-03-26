% fourier series definition of wavemaker position
clear
% close all
clc

%% User controls via sliders
mode = 1; % 1: regular, 2: sea state
Hm0 = 5;
Tp = 1/3;
gamma = 3.3;

%% Do in Processing GUI

frange = [1,4];

fund = 1/30; % fundamental frequency (Hz)
w0 = fund*2*pi; % rad/s fundamental frequency
tRep= 1/fund; % repeat time (1/Hz)
dt = 0.001;
t = dt:dt:2*tRep;

switch mode
    case 1
        N = 1;
        fs_indices = round(1/Tp/fund);
        Amp = Hm0/2;
        phase = 0;
        S.S = Amp^2/(fund*2*pi*2);
        S.w = fs_indices*w0;
    case 2
        fs_indices = round(frange(1)/fund) : round(frange(2)/fund);
        S = jonswap(2*pi*fund*fs_indices,[Hm0,Tp,gamma]); % Zach has written this in Java for us
        Amp = sqrt(2*S.S*2*pi*fund);
        phase = rand(1,length(fs_indices))*2*pi; % phase vector
end

Nf = length(fs_indices);

% Pass to Arduino: w0, Amp, fs_indices, phase

%% Do on Arduino

out=0; % initialize
for k= 1:Nf
    out=out + Amp(k)* sin(((fs_indices(k)*w0)).*t + phase(k));
end

%% check plots (MATLAB only)

figure
plot(t,out);
grid on; hold on;
xlabel('Time (s)')
ylabel('Amplitude (cm)')

figure
hold on
grid on
stem(S.w/(2*pi),S.S*2*pi,'.-')
win = ones(tRep/dt,1);
nov = floor(tRep/dt*0.5);
mnfft = tRep/dt;
[pxx,fwelch] = pwelch(out,win,nov,mnfft,1/dt,'onesided','psd');
stem(fwelch,pxx)
xlim([0,5])
ylabel('[cm^2/Hz]')
legend('Orig.','Welch')
