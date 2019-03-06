function [e]=create_excitation_signal(nframes,R,pitch)
% convert pitch period contour to excitation signal by appropriately
% placing pitch impulses and noise signals to match pitch period contour
% INPUTS
%   nframes: number of frames of speech signal lpc analysis and pitch
%   period contour
%   R: analysis frame shift in samples
%   pitch: pitch period contour at fsd=8000 samples per second
%   fidw: channel ID for debug printing and output
% OUTPUT
%   e: excitation error signal for lpc synthesis
% begin process of creating lpc excitation error signal for synthesis
    pprev=0;
    e=[]; % excitation signal from pitch contour consisting of unity 
          % height impulses and Gaussian noise, [R,nframes]
          
% begin excitation creation by placing pitch impulses at appropriate time
% samples along the waveform
for i=1:nframes;
        ppd=pitch(i);
        if(ppd == 0)
            e=[e randn(R,1)];
        else
            exc=zeros(R,1);
            if(pprev==0)
                exc(1)=1;
                loc=1;
           % fprintf(fidw,'frame:%d, loc:%d, pitch period:%d \n',i,loc,ppd);
                while (ppd+loc < R)
                    exc(loc+ppd)=1;
                    loc=loc+ppd;
               %     fprintf(fidw,'frame:%d, loc:%d, pitch period:%d \n',i,loc,ppd);
                end
            else
               loc=loc-R;
               if (loc+ppd <1)
                   loc=1-ppd;
               end
               while(loc+ppd < R)
                   exc(loc+ppd)=1;
                   loc=loc+ppd;
              %     fprintf(fidw,'frame:%d, loc:%d, pitch period:%d \n',i,loc,ppd);
               end
           end
           e=[e exc];
       end
       pprev=ppd;
end
% extend excitation by 3 R sample frames of zeros at end
    e=[e zeros(R,1) zeros(R,1) zeros(R,1)];
end