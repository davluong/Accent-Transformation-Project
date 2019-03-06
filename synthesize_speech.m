function [s]=synthesize_speech(ss,es,L,R,nframes,isyn,e,Gfile,Afile,p,of,win)
% do synthesis via overlap-add method
% if isyn is method 1, use L-length excitation frames, filter each by
% current LPC system, weight by L-length Hamming window, and overlap and
% add the results on a frame-by-frame basis
%
% if isyn is method 2, use R length excitation frames, supplemented by
% (of*R) length zero-valued frames; filter the excitation by the current LPC
% system and add the result directly to the existing accumulated sum
% INPUTS
%   ss: starting sample of first analysis frame
%   es: ending sample of last analysis frame
%   L: analysis frame length in samples
%   R: analysis frame shift in samples
%   isyn: synthesis method (1 for L sample length frames with Hamming
%   window overlap-addition across frames; 2 for R sample length frames
%   with rectangular window overlap across frames)
%   e: normalized excitation sequence
%   Gfile: sequence of frame gains
%   Afile: sequence of lpc frame vectors
%   p: lpc analysis order
%   of: offset between adjacent frames
%   win: window for lpc analysis
% initialize memory for lpc synthesis
    s=zeros((es-ss+1+L),1);
    
% begin the lpc synthesis loop
for i=1:nframes
            if (isyn == 3)
                ein=[e(1:R,i);zeros(of*R,1)];
                Gain=Gfile(i)/(sqrt(sum(ein.^2))+0.01);
                sout=filter(Gain,Afile(1:p+1,i),ein);
                if (i==1)
                    s(1:(of+1)*R)=sout(1:(of+1)*R);
                    send=(of+1)*R;
                else
                    s(send-of*R+1:send+R)=s(send-of*R+1:send+R)+sout(1:(of+1)*R);
                    send=send+R;
                end
            elseif (isyn == 2)
                ein=[e(1:R,i); e(1:R,i+1); e(1:R,i+2); e(1:R,i+3)];
                Gain=Gfile(i)/(sqrt(sum(ein.^2))+0.01);
                sout=filter(Gain,Afile(1:p+1,i),ein);
                if (i==1)
                       s(1:4*R)=sout(1:4*R).*win(1:4*R)';
                       send=4*R;
                else
                    s(send-3*R+1:send+R)=s(send-3*R+1:send+R)+...
                        sout(1:4*R).*win(1:4*R)';
                    send=send+R;
                end
            elseif (isyn == 1)
                ein=[e(1:R,i); e(1:R,i+1); e(1:R,i+2); e(1:R,i+3); zeros(L,1)];
                Gain=Gfile(i)/(sqrt(sum(ein.^2))+0.01);
                sout=filter(Gain,Afile(1:p+1,i),ein);
                if (i==1)
                       s(1:4*R+L)=sout(1:4*R+L);
                       send=4*R;
                else
                    s(send-3*R+1:send+R+L)=s(send-3*R+1:send+R+L)+...
                        sout(1:4*R+L);
                    send=send+R;
                    if send+R+L > length(s)
                        break
                    end
                end
            end
end
end