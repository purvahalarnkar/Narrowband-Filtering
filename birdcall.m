clc
clear all
close all

[s,f]=audioread('birdcall.wav');

%% Time Domain
n=length(s);
time=(0:n-1)/f;
b=bsxfun(@plus,s,[0.6 0]);
plot(time,b)
xlabel('Time(s)')
title('Time Domain')
 
 %% Frequency Domain
hz=linspace(0,f/2,floor(n/2)+1);
s_f=abs(fft(detrend(s(:,1))/n)).^2;
figure
plot(hz,s_f(1:length(hz)))
set(gca,'xlim',[0 8000])
xlabel('Frequency(Hz)')
title('Frequency Domain')

%% Time-frequency analysis
[spect,freq,t]=spectrogram(detrend(s(:,2)),hann(1000),100,[],f);
figure
imagesc(t,freq,abs(spect).^2)
axis xy
set(gca,'clim',[0 1]*2,'ylim',freq([1 dsearchn(freq,15000)]),'xlim',t([1 end]))
colormap hot
xlabel('Time(s)')
ylabel('Frequency(Hz)')
title('Spectrogram')

%% Select frequency ranges (visual inspection)
frange{1}=[1700 2600];
frange{2}=[5100 6100];

%draw boundary lines on the plot
colorz='bg';
hold on
for fi=1:length(frange)
    plot(get(gca,'xlim'),[1,1]*frange{fi}(1),[colorz(fi) '--'])
    plot(get(gca,'xlim'),[1,1]*frange{fi}(2),[colorz(fi) '--'])
end

%% Apply FIR filters

%initialize output matrix
filtered_signal=cell(2,1);
for filteri=1:length(frange)
    order=round(10*f/frange{1}(1));
    filtkern=fir1(order,frange{filteri}/(f/2));
    
    for channeli=1:2
        data_channel1=s(:,channeli);
        
        %zero-phase-shift filter with reflection
        sigR=[data_channel1(end:-1:1);data_channel1;data_channel1(end:-1:1)]; %reflect
        fsig=filter(filtkern,1,sigR); %forward filter
        fsig=filter(filtkern,1,fsig(end:-1:1)); %reverse filter
        fsig=fsig(end:-1:1); %zero again for 0phase
        fsig=fsig(n+1:end-n); %chop off reflected part
        
        filtered_signal{filteri}(:,channeli)=fsig;
    end
end

%% play

soundsc(s,f)
 
%lower frequency
soundsc(filtered_signal{1},f)

%higher frequency
soundsc(filtered_signal{2},f)  