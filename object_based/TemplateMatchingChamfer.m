function [windowCandidates] = TemplateMatchingChamfer(im, pixelCandidates, pixel_method)

distance_threshold=50000;
%Load histogram
histogram = loadHistograms('joint', pixel_method,'');
%Normalize histogram
histogram = histogram/max(max(histogram));
color_threshold=4000;
gray=rgb2gray(im);
%edges=edge(gray, 'canny');
edges2=edge(gray);
%edges2=edge(pixelCandidates);
D2=bwdist(edges2);
%D1=bwdist(edges);
tic
box=[];
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
triangle=ones(tempsize, round(tempsize*1.01));
triangle(tempsize,:)=0;
for i=1:round(tempsize*1.01)
    if i<round(tempsize/2)
        triangle(round(tempsize)-2*i,i)=0;
    else
        triangle(2*i-round(tempsize*1.01)+3,i)=0;
    end
end


for tempsize=45:10:220
    distance_thresh=distance_threshold*tempsize/220;
    color_thresh=color_threshold*tempsize/220;
    %interpolate templates
    TC=imresize(circ,tempsize/60);
    TR=imresize(rect, tempsize/60);
    TT=imresize(triangle, tempsize/60);
    maxsize=max([size(TC,1), size(TT,1), size(TR,1)]);
    for i=1:10:(size(D2,1)-maxsize)
        for j=1:12:(size(D2,2)-maxsize)
            distanceC=sum(sum(D2(i:(i+size(TC,1)-1), j:(j+size(TC,2)-1)).*TC));
            distanceT=sum(sum(D2(i:(i+size(TT,1)-1), j:(j+size(TT,2)-1)).*TT));
            distanceR=sum(sum(D2(i:(i+size(TR,1)-1), j:(j+size(TR,2)-1)).*TR));
            if min([distanceC, distanceT, distanceR])<distance_thresh
                if distanceC < min([distanceR, distanceT])  
                    w=size(TC,2)-1;
                    h=size(TC,1)-1;
                    thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TC,1)-1), j:(j+size(TC,2)-1),:), pixel_method, histogram)));
                elseif distanceR < min([distanceC, distanceT]) 
                    w=size(TR,2)-1;
                    h=size(TR,1)-1;
                    thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TR,1)-1), j:(j+size(TR,2)-1),:), pixel_method, histogram)));
                else
                    w=size(TT,2)-1;
                    h=size(TT,1)-1;
                    thresh=sum(sum(CandidateGenerationPixel(im(i:(i+size(TT,1)-1), j:(j+size(TT,2)-1),:), pixel_method, histogram)));
                end
                if thresh>color_thresh
                    %max_thresh=thresh;
                    %min_distance=distance;
                    box=[box; [j, i, w, h]];
                end
            end
        end
    end    

end
windowCandidates=box;
toc
end
    