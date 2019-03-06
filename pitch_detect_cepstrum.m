function [pd1,pd2,p1,p2]=pitch_detect_cepstrum(peaksigo,fsd,...
        nfft,L,R)
%
% function to detect primary and secondary cepstral pitch periods
%
% Inputs:
%   peaksigo: highpass filtered input signal for cepstral analysis
%   fsd: input signal sampling rate
%   imf: 1 for male talkers, 2 for female talkers
%   nfft: size of fft for stft computation
%   L: frame duration in samples
%   R: frame shift in samples
%   filename: name of file being processed
%
% Outputs:
%   pd1: pitch period contour based on first candidate
%   pd2: pitch period contour based on second candidate
%   p1: cepstral level at primary cepstral peak 
%   p2: cepstral level at secondary cepstral peak 
%
%   low pitch period corresponds to 300 Hz pitch
%   high pitch period corresponds to 50 Hz pitch
% initialize pd1 and p1
    clear pd1 p1;
    
% set cepstral ranges for male and female talkers
%     if (imf == 1)
%         ppdlow=round(fsd/250);
%         ppdhigh=round(fsd/60);
%     elseif (imf == 2)
%         ppdlow=round(fsd/350);
%         ppdhigh=round(fsd/150);
%     end
%     
ppdlow=round(fsd/350);
ppdhigh=round(fsd/60);
% block input signal into frames of duration L samples, with R sample
% shifts between frames
    ls=length(peaksigo);
    fcenter=L/2;
    
% initialize pitch period and pitch level arrays
    p1=[];
    p2=[];
    pd1=[];
    pd2=[];
%     count=1;
%     n=ppdlow:ppdhigh;
    
    while (fcenter+L/2 <= ls)
        frame1=peaksigo(max(fcenter-L/2,1):fcenter+L/2);
        lf=length(frame1);
        
% create small random frame if input == 0
        if (max(frame1) < 2)
            frame1=randn(lf,1)*0.001;
        end
        
% window frame and compute real cepstrum
        frame1=frame1.*hamming(lf);
        frame1(lf+1:nfft)=0;
        frame1t=log(abs(fft(frame1,nfft)))';
        framec=ifft(frame1t,nfft);
        
% initialize local frame cepstrum over valid range from ppdlow to ppdhigh
        indexlow=ppdlow+1;
        indexhigh=ppdhigh+1;
        loghsp=framec(indexlow:indexhigh);
        
% find cepstral peak location (ploc) and level (pmax) and save results in
% pd1 (for ploc) and p1 (for pmax)
        pmax=max(loghsp);
        ploc1=find(loghsp == pmax);
        ploc=ploc1+ppdlow-1;
        p1=[p1 pmax];
        pd1=[pd1 ploc];
        
% eliminate strongest peak in order to find highest secondary peak 
% which is spaced away from primary peak
% save secondary peak in pd2 and secondary level in p2
        n1=max(1,ploc1-4);
        n2=min(ploc1+4,length(loghsp));
        loghsp2=loghsp;
        loghsp2(n1:n2)=0;
        pmax2=max(loghsp2);
        p2=[p2 pmax2];
        ploc2=find(loghsp2 == pmax2);
        ploc2=ploc2+ppdlow-1;
        pd2=[pd2 ploc2];
  
% plot cepstral values if debug mode is on
        fcenter=fcenter+R;        
    end
end