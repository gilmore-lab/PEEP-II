function [] = testaudiochannels(minutes,freq)
%minutes = number of minutes to play test
%freq = frequency to play test
%this function will play a 440 Hz signal through the left ear for 2 seconds
%and then 440Hz signal through the right ear for 2 seconds
if(nargin<2)
    freq =1000;
end
if(nargin<1)
    minutes = 1;
    freq = 1000;
end

T = 2;
fs = 44100;
dt = 1/fs;
N = T*fs;
nloops = floor(minutes*60/T);

w = freq*2*pi;
tt = (0:N-1).*dt;
sigL = zeros(N,2);
sigR = zeros(N,2);
sigL(:,1) = sin(w.*tt);
sigR(:,2) = sin(w.*tt);
xL=sigL;
xR = sigR;
p = 0.005;

if(mod(N,2)==0)
    m = floor(N*p);
    if(mod(m,2)~=0)
        taper = ones(m-1,2);
        taper(:,1) = hann(m-1);
        taper(:,2) = hann(m-1);
    else
        taper = ones(m,2);
        taper(:,1) = hann(m);
        taper(:,2) = hann(m);
    end
    taper1=taper(1:floor(length(taper)/2),:);
    taper2=taper(floor(length(taper)/2)+1:end,:);
    xL(1:floor(length(taper)/2),:)=xL(1:floor(length(taper)/2),:).*taper1;
    xL(end-floor(length(taper)/2)+1:end,:)=xL(end-floor(length(taper)/2)+1:end,:).*taper2;
    xR(1:floor(length(taper)/2),:)=xR(1:floor(length(taper)/2),:).*taper1;
    xR(end-floor(length(taper)/2)+1:end,:)=xR(end-floor(length(taper)/2)+1:end,:).*taper2;
end

disp('Beginning audio channel test, PRESS SPACEBAR TO BEGIN')
pause
disp(['Playing test for ',num2str(minutes*60),' (s) ',num2str(T),' [s] per channel.'])
a = 1;
for ii = 1:nloops
    if(a == 1)
        player = audioplayer(xL,fs);
        disp('Playing signal out of LEFT channel')
        playblocking(player)
    end
    if(a ==-1)
        player = audioplayer(xR,fs);
        disp('Playing signal out of RIGHT channel')
        playblocking(player)
    end
    a = a*-1;
end