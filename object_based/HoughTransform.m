function [ windowCandidates ] = HoughTransform(im, pixelCandidates)
%HOUGHTRANSFORM Summary of this function goes here
%   Detailed explanation goes here
%figure(f);
plotting=true;
tic
%extract contours
pc_edges =  bwperim(pixelCandidates,8);
%dilate contour
se=strel('disk',3);
pc_edges=imdilate(pc_edges,se);
%thin contour
%pc_edges=bwmorph(pc_edges,'thin','Inf');
if plotting
subplot(2,2,1)
imshow(pixelCandidates)
end
%hough transform
[H, theta,rho]=hough(pc_edges);
%subplot(2,2,3)
%show hough transform
% imshow(H,[],'XData',theta,'YData',rho,...
%     'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
%calculate peaks in HT
%
P  = houghpeaks(H,50,'threshold',ceil(0.3*max(H(:))));
%P  = houghpeaks(H,100);
%plot peaks in HT
%x = theta(P(:,2)); y = rho(P(:,1));
%plot(x,y,'s','color','white');
%hold off;
%exract lines from HT and its peaks
lines = houghlines(pc_edges,theta,rho,P,'FillGap',50,'MinLength',20);
thetas=[];
rhos=[];
if plotting
subplot(2,2,2), imshow(pc_edges), hold on
for k = 1:length(lines)
    thetas=[thetas lines(k).theta];
    rhos=[rhos lines(k).rho];
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end
hold off
end

%%%%% HOUGH Heuristics
if(~isempty(lines))
%cell with different detected shapes. Every shape is a vector with vector
%'lines' positions
shapes={};
j=1;
%vector with 'lines' indexes where a single shape is formed
shape=[];
%pool vector is the lines vector positions where a shape has not been
%assigned yet. Initialized with all the positions.
pool=1:length(lines);

%segment index to analyse. Initialized with the first index in 'pool'.
if ~isempty(pool)
ind=pool(1);
end
%initialized 'end_seg' as point2
end_seg=2;
while (~isempty(pool)) %while pool still has candidates without assignment to a shape
%theta angle as reference to compare further segments.
 ref_theta=lines(ind).theta;
 %always store current index in a shape. If further segments are in no
 %relation, it will be a shape with just one segment and,
 %therefore,discarded.
 shape=[shape ind];
   
%find closest segment ('lines' index) to target segment 'ind'
[closest_ind,end_seg_]=findClosestPoint(lines,pool,ind,end_seg); %-1 if no close segments
%theta diference between current index candidate and closest index
if(end_seg_~=0)
    end_seg=end_seg_;
else
    end_seg=2;
end

%if a close segment fits triangle heuristics, erase previous segment 'ind'
%from pool.
    pool(find(pool==ind))=[];

if closest_ind~=-1 
    theta_diff=abs(ref_theta-lines(closest_ind).theta);
    if(theta_diff<10  || (theta_diff<90 && theta_diff>20)) 

    %take next ind as closest_ind
     ind=closest_ind;
    else
    %finish the current shape and store it in 'shapes' cell.
    shapes{j}=shape;
    j=j+1;
    %restart 'shape'
    shape=[];
     %if the closest segment doesn't fit in the triangle heuristics, take
    %next segment to consider as the first one in the pool
    if (~isempty(pool))
    ind=pool(1);
    end
    end
else %if there is no close segment or the closest segment does not belong to the shape's heuristics
    %finish the current shape and store it in 'shapes' cell.
    shapes{j}=shape;
    j=j+1;
    %restart 'shape'
    shape=[];
     %if the closest segment doesn't fit in the triangle heuristics, take
    %next segment to consider as the first one in the pool
    if (~isempty(pool))
    ind=pool(1);
    end
end
    
%eliminate shapes without at least 3 segments
def_shapes={};
i=1;
for s=1:length(shapes)
    shape_=shapes{s};
    if(length(shape_)>2)
        def_shapes{i}=shapes{s};
        i=i+1;
    end
end
end
disp(['Num shapes before filter shape ' int2str(length(def_shapes))]);
def_shapes_={};
k=1;

for i=1:length(def_shapes)
    shape=def_shapes{i};
    disp(['shape num' int2str(i)]);
    min_angle=1800;
    max_angle=-1800;
    for j=1:length(shape)
        if lines(shape(j)).theta<min_angle
        min_angle=lines(shape(j)).theta;
        end
        if lines(shape(j)).theta> max_angle
        max_angle=lines(shape(j)).theta;
        end
        
    end
    max_diff=abs(max_angle-min_angle);
    if max_diff>25 %then the shape is not a straight line, keep shape
    def_shapes_{k}=shape;
    k=k+1;
    end
end
disp(['Num shapes after filter shape ' int2str(length(def_shapes_))]);
if plotting
%show lines in contour image
subplot(2,2,3)
imshow(pc_edges), hold on
for i=1:length(def_shapes_)
   vec= def_shapes_{i};
   if i==1
   color='green';
   elseif i==2
       color='red';
   elseif i==3
       color='blue';
   elseif i==4
       color='magenta';
   else
       color='yellow';
   end
for k = 1:length(vec)
    xy = [lines(vec(k)).point1; lines(vec(k)).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color',color);
end
end
hold off
end
end %end if lines is not empty

%%%%% HOUGH Heuristics

%get BB from shape

windowCandidates=[];
for i=1:length(def_shapes_)
   bb=getBoundingBox(lines,def_shapes_{i});
    windowCandidates=[windowCandidates; bb];                             
end
if plotting
h=subplot(2,2,4); imshow(pc_edges,'Parent',h),hold on
  for zz = 1:size(windowCandidates,1)
      w=windowCandidates;
          r=rectangle(h,'Position', [w(zz,1), w(zz,2), w(zz,3), w(zz,4)], 'LineWidth',2,'EdgeColor','b');
               
  end     
drawnow
waitforbuttonpress
end
toc
end

function [closest_ind,end_seg_]=findClosestPoint(lines,pool,ind,end_seg)
%find closest point to lines(ind) in lines
%window size;
w=40;
%evaluate window around point1 or point2, depending on the point previously
%matched as candidate in last iteration.
end_seg_=0;
if end_seg==2
ref=lines(ind).point2;
elseif end_seg==1
ref=lines(ind).point1;
end
theta_ref=lines(ind).theta;
%closest candidates with point1
closest_candidates_p1=[];
%closest candidates with point2
closest_candidates_p2=[];
%now, lines are only the ones in the pool
%lines=lines(pool);
for i=-w:1:w
    for j=-w:1:w
        ref_point=[ref(1)+i,ref(2)+j];%construct 'ref_point' as the exact point to look for inside the window. 
        for l=1:length(pool)
            %if a point1 or point2 in lines match the 'ref_point', a
            %closest_candidate has been found.
        if isequal(lines(pool(l)).point1,ref_point)  && ind~=l 
            closest_candidates_p1=[closest_candidates_p1; pool(l)];
        elseif  isequal(lines(pool(l)).point2,ref_point) && ind~=l
              closest_candidates_p2=[closest_candidates_p2; pool(l)];
        end
       
        end
    end
end
%algorithm to discard closest_candidates
min_mse=1000;
min_ind=-1;
%theta_diff=
for i=1:length(closest_candidates_p1)
    cc=lines(closest_candidates_p1(i)).point1;
    mse=(abs(ref(1)-cc(1))^2+abs(ref(2)-cc(2))^2)/2;
    if mse<min_mse
        min_mse=mse;
        min_ind=closest_candidates_p1(i);
        end_seg_=1;
    end
end
for i=1:length(closest_candidates_p2)
    cc=lines(closest_candidates_p2(i)).point2;
    mse=(abs(ref(1)-cc(1))^2+abs(ref(2)-cc(2))^2)/2;
    if mse<min_mse
        min_mse=mse;
        min_ind=closest_candidates_p2(i);
        end_seg_=2;
    end
end
closest_ind=min_ind;

end

function [bb]=getBoundingBox(lines, shape)
%get bounding box just considering 'lines' with the indexes in 'shape' vector 
max_y=0;
min_y=1000000000;
max_x=0;
min_x=1000000000;
for i=1:length(shape)
  point= lines(shape(i)).point1;
  if (point(1)>max_y)
      max_y=point(1);
  end
  if point(1)<min_y
      min_y=point(1);
  end
  if point(2)>max_x
      max_x=point(2);
  end
  if point(2)<min_x
      min_x=point(2);
  end
   point= lines(shape(i)).point2;
    if (point(1)>max_y)
      max_y=point(1);
    end
  if point(1)<min_y
      min_y=point(1);
  end
  if point(2)>max_x
      max_x=point(2);
  end
  if point(2)<min_x
      min_x=point(2);
  end
end
% bb=[min_x,min_y,max_x-min_x, max_y-min_y];
 bb=[min_y,min_x,max_y-min_y, max_x-min_x];
end
