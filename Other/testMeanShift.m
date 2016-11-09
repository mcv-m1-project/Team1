function [Ims] = testMeanShift(Im, histogram)
tic
Im = im2double(Im);
Im = rgb2hsv(Im);
sc=1/4;
I=imresize(Im, sc);
% [x,y] = meshgrid(1:size(I,2),1:size(I,1)); 
% L = [y(:)/max(y(:)),x(:)/max(x(:))]; % Spatial Features
% C = reshape(I,size(I,1)*size(I,2),3); X = [C,L]; 
%grays = 40;
%histogram(:,1:grays)=0;
%histogram = histogram / max(max(histogram));
I1D=rgb2gray(I);
X = reshape(I,size(I,1)*size(I,2),3); 
X1 = reshape(I1D,size(I1D,1)*size(I1D,2),1); 
bandwidth=0.15;
[clustCent,point2cluster,clustMembsCell] = MeanShiftCluster(X',bandwidth, 'flat');
%[clustCent,point2cluster,clustMembsCell] = MeanShiftCluster(X',bandwidth, 'gaussian');
[x,y]=find(clustCent(1:2,:)>=1);
for i=1:size(x)
    clustCent(x,y)=1;
end

for i = 1:length(clustMembsCell)   % Replace Image Colors With Cluster Centers
    X(clustMembsCell{i},:) = repmat(clustCent(:,i)',size(clustMembsCell{i},2),1);
    %if ((clustCent(1,i)>= 0.925 || clustCent(1,i)<= 0.059  || (clustCent(1,i)>= 0.479 && clustCent(1,i)<= 0.762)) && (clustCent(2,i)>= 0.2 &&clustCent(3,i)>= 0.1))
    if ((clustCent(1,i)>= 0.9 || clustCent(1,i)<= 0.1  || (clustCent(1,i)>= 0.4 && clustCent(1,i)<= 0.8)) && (clustCent(2,i)>= 0.2 &&clustCent(3,i)>= 0.1))
        X1(clustMembsCell{i}) = 255;
    else
        X1(clustMembsCell{i}) = 0;
    end
end
%Ims = reshape(X(:,1:3),size(I,1),size(I,2),3); 
Ims = reshape(X1(:), size(I,1), size(I,2));
Ims2 = reshape(X(:,1:3),size(I,1),size(I,2),3); 
% Segmented Image
%Ims=hsv2rgb(Ims);
Ims2=hsv2rgb(Ims2);
Ims=imresize(Ims, 1/sc);
Ims2=imresize(Ims2, 1/sc);
toc
end