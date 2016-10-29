function [ windowCandidates ] = ConvSlidingWindow(mask, split, r, c, shape )
%CONVSLIDINGWINDOW Summary of this function goes here
%   Detailed explanation goes here
windowCandidates = [];


%Depending on the split, the mask has a different size than the original
%image, so the "(0,0)" is different. Define an initial i and initial j, as
%an offset to be able to compare both images later
if split == 1 || split == 5 || split == 7 || split == 9
    inii = 1;
    inij = 1;
elseif split == 2 || split == 6 || split == 8
    inii = 1;
    inij = round(c/2)+1;
elseif split == 3
    inii = round(r/2)+1;
    inij = 1;
elseif split == 4
    inii = round(r/2)+1;
    inij = round(c/2)+1;
end

%Find the position of the first '1'
[idxi,idxj] = find(mask);
inir = min(idxi);
inic = min(idxj);
lastr = max(idxi);
lastc = max(idxj);
mask = mask(inir:lastr,inic:lastc);

inii = inii + inir -1;
inij = inij + inic -1;

if strcmp(shape,'tri')
    %Create triangles of different sizes and compute the cross correlation with
    %the mask. Where the correlation is higher than a certain value, we assume
    %that there is an triangular signal.
    for h = 40:10:170
        %If the template is bigger than the mask, stop looking
        if h > size(mask,1) || h > size(mask,2)
            break
        end
        tri = ones(h,h);
        for i = 1:h
            for j = 1:h
                if (j <= h/2 && (i/2+j<h/2)) || j > h/2 && (-i/2+j>h/2)
                    tri(i,j)=0;
                end
            end
        end
        
        %Compute the cross correlation
        C = normxcorr2(tri, mask);
        
        if max(max(C)) > 0.8
            [~, peaks] = FastPeakFind(C);
            [ypeak,xpeak] = find(peaks);
            
            for n = 1:size(ypeak,1)
                if C(ypeak(n),xpeak(n))>0.7
                    yoffSet = ypeak(n)-size(tri,1) + inii;
                    xoffSet = xpeak(n)-size(tri,2) + inij;
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                    windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(tri,2), size(tri,1)]];
                end
            end
        end
    end
    
elseif strcmp(shape,'circ')
    %Create circles of different sizes and compute the cross correlation with
    %the mask. Where the correlation is higher than a certain value, we assume
    %that there is an circular signal.
    for rad = 30:10:160
        %If the template is bigger than the mask, stop looking
        if rad > size(mask,1) || rad > size(mask,2)
            break
        end
        [rr, cc] = meshgrid(1:rad);
        circ = sqrt((rr-rad/2).^2+(cc-rad/2).^2)<=rad/2;
        
        %Compute the cross correlation
        C = normxcorr2(circ, mask);
        
        if max(max(C)) > 0.8
            [~, peaks] = FastPeakFind(C);
            [ypeak,xpeak] = find(peaks);
            for n = 1:size(ypeak,1)
                if C(ypeak(n),xpeak(n))>0.7
                    yoffSet = ypeak(n)-size(circ,1) + inii;
                    xoffSet = xpeak(n)-size(circ,2) + inij;
                    windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(circ,2), size(circ,1)]];
                end
            end
        end
    end
elseif strcmp(shape,'invtri')
    %Create triangles of different sizes and compute the cross correlation with
    %the mask. Where the correlation is higher than a certain value, we assume
    %that there is an triangular signal.
    for h = 40:10:170
        %If the template is bigger than the mask, stop looking
        if h > size(mask,1) || h > size(mask,2)
            break
        end
        tri = ones(h,h);
        for i = 1:h
            for j = 1:h
                if (j<=h/2 && -i/2+j<0) || (j>h/2 && i/2+j>h)
                    tri(i,j)=0;
                end
            end
        end
        
        %Compute the cross correlation
        C = normxcorr2(tri, mask);
        
        if max(max(C)) > 0.7
            [~, peaks] = FastPeakFind(C);
            [ypeak,xpeak] = find(peaks);
            
            for n = 1:size(ypeak,1)
                if C(ypeak(n),xpeak(n))>0.7
                    yoffSet = ypeak(n)-size(tri,1) + inii;
                    xoffSet = xpeak(n)-size(tri,2) + inij;
                    windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(tri,2), size(tri,1)]];
                end
            end
        end
    end
elseif strcmp(shape,'rect')
    %Find the connected components in the image. Check their filling ratio
    %and aspect ratio and classify them as signals or not.
    CC = bwconncomp(mask);
    stats = regionprops(CC, 'BoundingBox');
    N = length(stats);
    if N == 0
        return
    end
    for m=1:N
        bb = ceil(stats(m).BoundingBox);
        i1 = bb(2);
        i2 = i1 + bb(4)-1;
        j1 = bb(1);
        j2 = j1 + bb(3)-1;
        maskm = mask(i1:i2,j1:j2);
        C = sum(sum(maskm))/numel(maskm);
        if C > 0.7 && (bb(3)/bb(4)>0.5) && (bb(3)/bb(4)<1.1)
            bb(1) = bb(1) + inij;
            bb(2) = bb(2) + inii;
            windowCandidates = [windowCandidates; bb];
        end

    end
    
end


end

