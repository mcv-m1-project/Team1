function [windowCandidates] = TemplateMatchingChamfer(im, pixelCandidates, pixel_method)
tic
distance_threshold=50000;
%Load histogram
histogram = loadHistograms('joint', pixel_method,'');
%Normalize histogram
histogram = histogram/max(max(histogram));
color_threshold=3500;
%gray=rgb2gray(im);
%TODO: Smoothing filter
smooth=imgaussfilt(im,1.5);
gray=rgb2gray(smooth);
%edges=edge(gray, 'canny');
%edges2=imcontour(pixelCandidates,1);
%edges2=edge(gray);
se = strel(ones(3,3));
edges2 = imdilate(gray, se) - imerode(gray, se);
D2=bwdist(edges2);
%D1=bwdist(edges);
windowCandidates=[];
inii = 0;
inij = 0;
%%Circle template for the minimum size
tempsize=60;
circ=ones(tempsize, round(tempsize*0.95));
nseg=1000;
a=round(tempsize/2)-1;
b=round(round(tempsize*0.95)/2)-1;
yc=b+1;
xc=a+1;
for theta = 0 : (2 * pi / nseg) : (2 * pi)
    pline_y = abs(b * sin(theta) + yc);
    pline_x = abs(a * cos(theta) + xc);
    circ(round(pline_x),round(pline_y))=0;
end
%%Rectangle template for the minimum size:
rect=ones(tempsize, round(tempsize*0.83));
rect(1:2,:)=0;
rect(tempsize-1:tempsize,:)=0;
rect(:,1:2)=0;
rect(:,round(tempsize*1.01)-1:round(tempsize*0.83))=0;

%%triangle template for the minimum size:

h1=tempsize;
h2=round(tempsize*1.01);
triangle=ones(h1, h2);
for i = 1:h1
    for j = 1:h2
        if (j <= h2/2 && (i/2+j==h2/2-1)) || (j > h2/2 && (-i/2+j==h2/2-1)) || (i==h1-1)
            triangle(i,j)=0;
        end
    end
end


for tempsize=60:10:190
    %distance_thresh=distance_threshold*tempsize/220;
    %color_thresh=color_threshold*tempsize/220;
    %interpolate templates
    TC=imresize(circ,tempsize/60);
    TR=imresize(rect, tempsize/60);
    TT1=imresize(triangle, tempsize/60);
    TT2=ones(size(TT1));
    for i=1:size(TT1,1)
        TT2(i,:)=TT1(size(TT1,1)-i+1,:);
    end
    normC=normxcorr2(TC,D2);
    normR=normxcorr2(TR,D2);
    normT1=normxcorr2(TT1,D2);
    normT2=normxcorr2(TT2,D2);
    normC=max(max(normC))-normC;
    normR=max(max(normR))-normR;
    normT1=max(max(normT1))-normT1;
    normT2=max(max(normT2))-normT2;
    if max(max(normC)) > 0.8
            [~, peaks] = FastPeakFind(normC);
            [ypeak,xpeak] = find(peaks);
            for n = 1:size(ypeak,1)
                if normC(ypeak(n),xpeak(n))>0.7
                    yoffSet = ypeak(n) -size(TC,1);
                    xoffSet = xpeak(n)-size(TC,2);
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                    windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(triangle,2), size(triangle,1)]];
                end
            end
    end
    if max(max(normT1)) > 0.8
        [~, peaks] = FastPeakFind(normT1);
        [ypeak,xpeak] = find(peaks);
        for n = 1:size(ypeak,1)
            if normT1(ypeak(n),xpeak(n))>0.55
                    yoffSet = ypeak(n) -size(TT2,1);
                    xoffSet = xpeak(n)-size(TT1,2) + inij;
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(triangle,2), size(triangle,1)]];
            end
        end
    end
    if max(max(normT2)) > 0.8
        [~, peaks] = FastPeakFind(normT2);
        [ypeak,xpeak] = find(peaks);
        for n = 1:size(ypeak,1)
            if normT2(ypeak(n),xpeak(n))>0.55
                    yoffSet = ypeak(n);% -size(TT2,1);
                    xoffSet = xpeak(n)-size(TT2,2) + inij;
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(triangle,2), size(triangle,1)]];
            end
        end
    end
    if max(max(normR)) > 0.8
        [~, peaks] = FastPeakFind(normR);
        [ypeak,xpeak] = find(peaks);
        for n = 1:size(ypeak,1)
            if normR(ypeak(n),xpeak(n))>0.8
                    yoffSet = ypeak(n) -size(TR,1);
                    xoffSet = xpeak(n)-size(TR,2) + inij;
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(triangle,2), size(triangle,1)]];
            end
        end
    end
%     maxsize=max([size(TC,1), size(TT,2), size(TR,1)]);
%     for i=1:12:(size(D2,1)-maxsize)
%         for j=1:12:(size(D2,2)-maxsize)
%             distanceC=sum(sum(D2(i:(i+size(TC,1)-1), j:(j+size(TC,2)-1)).*TC));
%             distanceT=sum(sum(D2(i:(i+size(TT,1)-1), j:(j+size(TT,2)-1)).*TT));
%             distanceR=sum(sum(D2(i:(i+size(TR,1)-1), j:(j+size(TR,2)-1)).*TR));
%             if min([distanceC, distanceT, distanceR])<distance_thresh
%                 if distanceC < min([distanceR, distanceT])  
%                     w=size(TC,2)-1;
%                     h=size(TC,1)-1;
%                     thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TC,1)-1), j:(j+size(TC,2)-1),:), pixel_method, histogram)));
%                 elseif distanceR < min([distanceC, distanceT]) 
%                     w=size(TR,2)-1;
%                     h=size(TR,1)-1;
%                     thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TR,1)-1), j:(j+size(TR,2)-1),:), pixel_method, histogram)));
%                 else
%                     w=size(TT,2)-1;
%                     h=size(TT,1)-1;
%                     thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TT,1)-1), j:(j+size(TT,2)-1),:), pixel_method, histogram)));
%                 end
%                 if thresh>color_thresh
%                     box=[box; [j, i, w, h]];
%                 end
%             end
%         end
%    end    

end
%windowCandidates=box;
toc
end