function y=highpass_filter(x,fs)
% high pass filter recorded speeech to eliminate dc and hum
% x: original recorded speech
% fs: sampling rate in Hertz
%   y: high pass filtered speech
% design high pass filter to eliminate dc and hum
     fln=200/fs;
     fhn=400/fs;
     nl=200;
     fd=[0 fln fhn 1];
     ad=[0 0 1 1];
     bf=firpm(nl,fd,ad);
     
% filter input using highpass filter
     ye=[x; zeros(nl/2,1)];
     yf=filter(bf,1,ye);
     y=yf(1+nl/2:length(x)+nl/2);
end