function ppdf=smoothpitch(pp1,pp2,plevel1,plevel2,pthr1)
%
% pitch period smoothing routine based on first and second candidates and
% associated confidence levels
%
% Inputs:
%   pp1: array of most likely pitch period candidates at each frame
%   pp2: array of second most likely pitch period candidates at each frame
%   plevel1: cepstral levels of most likely pitch period candidates at each
%   frame
%   plevel2: cepstral levels of second most likely pitch period candidates 
%   at each frame
%   pthr1: threshold on reliable cepstral levels for valid pitch period
%   candidates
%
% Output:
%   ppdf: final smoothed pitch period contour
% first find all regions where cepstral level exceeds a reasonably 
% high threshold (i.e., low likelihood of mistakes); these regions
% form the basis for valid pitch period contour pieces
    len=length(pp1);
    n=1:len;
    
% utilize threshold on ratio of first and second cepstral peak values 
% and get a 0-1 contour
    pratio=plevel1./plevel2;
    ppdf=[0 ones(1,len-2) 0];
    ppdf(find(pratio < pthr1))=0;
    
% form difference signal to define beginnings of regions (ppdfd=1) and
% endings of regions (ppdfd=-1)
    ppdfd(2:len)=ppdf(2:len)-ppdf(1:len-1);
    ppdfd(1)=0;
    
% debug plotting of pratio contour along with ppdf contour and threshold
    idebug=0;
    if (idebug == 1)
        figure,plot(n,pratio(1:len),'k','LineWidth',2),axis tight, grid on, hold on;
        plot([0 len],[pthr1 pthr1],'b','LineWidth',2), hold on;
        plot(n,ppdf(1:len)*50,'r','LineWidth',2);
    end
    
% determine nint, the number of contiguous intervals in pitch contour;
% determine beginning frame of each interval, ppstart;
% determine ending frame of each interval, ppend;
    nint=0;
    ppstart=[];
    ppend=[];
    for frame=2:len
        if (ppdfd(frame) == 1)
            ppstart=[ppstart frame];
            nint=nint+1;
        elseif (ppdfd(frame) == -1)
            ppend=[ppend frame-1];
        end
    end
    
% debug printing of interval information
    idebug=0;
    if (idebug == 1)
        fprintf('before processing \n');
        for int=1:nint
            fprintf('int:%d, begin,end: %d %d \n',int,ppstart(int),ppend(int));
        end
        fprintf('\n');
    end
% begin search to extend each region backwards (at beginning of region) and
% forwards (at end of region); be sure not to go too far backward or
% forward to avoid overlapping with adjacent regions
    pdthr=0.1;
    
% for first interval, search backwards for possible extensions of region
    for frame=ppstart(1)-1:-1:2
        if (abs((pp1(frame)-pp1(frame+1))/pp1(frame+1)) <= pdthr)
            ppstart(1)=ppstart(1)-1;
        elseif (abs((pp2(frame)-pp1(frame+1))/pp1(frame+1)) <= pdthr)
            ppstart(1)=ppstart(1)-1;
            pp1(frame)=pp2(frame);
        else
            break
        end
    end
    
% for all other intervals, search backward for extensions to interval, 
% being careful not to go into end of preceding region
    for intervals=2:nint
        for frame=ppstart(intervals)-1:-1:ppend(intervals-1)+1
            if (abs((pp1(frame)-pp1(frame+1))/pp1(frame+1)) <= pdthr)
                ppstart(intervals)=ppstart(intervals)-1;
            elseif (abs((pp2(frame)-pp1(frame+1))/pp1(frame+1)) <= pdthr)
                ppstart(intervals)=ppstart(intervals)-1;
                pp1(frame)=pp2(frame);
            else
                break
            end
        end
    end
    
% now search forward for extensions to interval, being careful not to go
% into beginning of next region
    for intervals=1:nint-1
        for frame=ppend(intervals)+1:ppstart(intervals+1)-1
            if (abs((pp1(frame)-pp1(frame-1))/pp1(frame)) <= pdthr)
                ppend(intervals)=ppend(intervals)+1;
            elseif (abs((pp2(frame)-pp1(frame-1))/pp1(frame)) <= pdthr)
                ppend(intervals)=ppend(intervals)+1;
                pp1(frame)=pp2(frame);
            else
                break
            end
        end
    end
    
% for final interval, search forward for possible extensions of region            
    for frame=ppend(nint)+1:len-1
        if (abs((pp1(frame)-pp1(frame-1))/pp1(frame)) <= pdthr)
            ppend(nint)=ppend(nint)+1;
        elseif (abs((pp2(frame)-pp1(frame-1))/pp1(frame)) <= pdthr)
            ppend(nint)=ppend(nint)+1;
            pp1(frame)=pp2(frame);
        else
            break
        end
    end
    
% debug printing of final intervals after processing
    if (idebug == 1)
        fprintf('after processing \n');
        for int=1:nint
            fprintf('int:%d, begin,end: %d %d \n',int,ppstart(int),ppend(int));
        end
        fprintf('\n');
    end
    
% zero out all pitch periods between intervals
    for frame=1:ppstart(1)-1
        pp1(frame)=0;
    end
    
    for interval=1:nint-1
        for frame=ppend(interval)+1:ppstart(interval+1)-1
            pp1(frame)=0;
        end
    end
    
    for frame=ppend(nint)+1:len
        pp1(frame)=0;
    end    
    ppdf=pp1;
end