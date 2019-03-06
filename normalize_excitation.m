function [ex,exn,Gain]=normalize_excitation(e,R,Gfile)
% appropriately normalize speech excitation signal based on measured Gain
% from lpc analysis
% INPUTS
%   e: unnormalized excitation signal
%   R: analysis frame shift in samples
%   nframes: number of analysis frames
%   Gfile: lpc gain sequence for each analysis frame
% OUTPUTS
%   ex: excitation signal blocked into R sample sections
%   exn: excitation properly gain normalized
%   Gain: lpc frame gain array
% normalize excitation signal and save as file
    ex=[];
    exn=[];
    nframes=length(Gfile);
    for i=1:nframes
        ex=[ex e(1:R,i)']; % ex is excitation blocked into R sample sections
        ein=e(1:R,i);
        Gain=Gfile(i)/(sqrt(sum(ein.^2))+0.01);
        exn=[exn Gain*e(1:R,i)']; % exn is excitation properly gain normalized
    end
end