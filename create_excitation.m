function e=create_excitation(pitch,R)
%
% create excitation function from pitch period array
% Inputs:
%   pitch: array of pitch period values; 0 for unvoiced or silence
%   fs: sampling rate of speech file
%   R: shift in samples between frames
% nframes is the number of frames in the pitch file
    nframes=length(pitch);
% LPC synthesis--create excitation sequence: voiced component, i.e., pitch
% pulses spaced at appropriate intervals, based on pitch contour previously
% read in
    % fprintf('beginning excitation function creation from pitch file \n');
    pprev=0;
    e=[]; % excitation signal from pitch contour consisting of unity 
          % height impulses and Gaussian noise, [R,nframes]
          
% begin timing loop for excitation creation
    tstart=tic;
    for i=1:nframes;
        ppd=pitch(i);
        if(ppd == 0)
            e=[e randn(1,R)*0.01];
        else
            exc=zeros(1,R);
            if(pprev==0)
                exc(1)=1;
                loc=1;
                % fprintf('frame:%d, loc:%d, pitch period:%d \n',i,loc,ppd);
                while (ppd+loc < R)
                    exc(loc+ppd)=1;
                    loc=loc+ppd;
                    % fprintf('frame:%d, loc:%d, pitch period:%d \n',i,loc,ppd);
                end
            else
               loc=loc-R;
               if (loc+ppd <1)
                   loc=1-ppd;
               end
               while(loc+ppd < R)
                   exc(loc+ppd)=1;
                   loc=loc+ppd;
                   % fprintf('frame:%d, loc:%d, pitch period:%d \n',i,loc,ppd);
               end
           end
           e=[e exc];
       end
       pprev=ppd;
    end
    
% end timing loop for excitation creation
    tend=toc(tstart);
    fprintf('time for excitation creation: %8.2f \n',tend);
end