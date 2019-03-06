function [p1m,pitch]=gen_pitch(xin,fs,L,R,nframes)
% cepstral pitch detector used to generate pitch period contour
% INPUTS
%   xin: input speech signal (usually scaled from -32768-to-32767)
%   ss: starting sample of first analysis frame
%   es: ending sample of last analysis frame
%   fs: sampling rate of original speech signal
%   imf: male/female pitch range switch; imf=1 for male; imf=2 for female
%   L: analysis frame length in samples
%   R: analysis frame shift in samples
%   nframes: number of frames in signal
% OUTPUTS
%   p1m: pitch period contour at original signal rate
%   pitch: pitch period contour at rate fsd=8000 samples per second
% generate pitch period file using cepstral pitch detector
        
% compute cepstrum and detect pitch
    nfft=4000;
    %filesave='out_cepstral.mat';
% cepstral pitch detector
    [pp1,pp2,plevel1,plevel2]=pitch_detect_cepstrum(xin,fs,nfft,...
        L,R);
    
% median smooth pitch period contour
    pthr1=1.9;
    ppdf=smoothpitch(pp1,pp2,plevel1,plevel2,pthr1);
    nl=length(ppdf);
    
% compute median pitch period and median log confidence scores
    Lmed=5;
    p1m=medf(ppdf,Lmed,length(pp1));
% normalize pitch periods to standard rate
    fsd=8000;
    pitch=round(p1m*fsd/fs);
    
% make sure that pitch and lpc have same number of frames
    if (nl < nframes)
        p1m(nl+1:nframes)=0;
        nl=nframes;
    end
end