function [windowCandidates] = TemplateMatchingCorrelation(templates)
%TemplateMatchingCorrelation( im, templates)
%TEMPLATECORRELATION Summary of this function goes here
%   Detailed explanation goes here

DATASET_PATH = 'DataSetDelivered';
TRAIN_DATASET_PATH = fullfile(DATASET_PATH, 'train');
[train_split, val_split] = read_train_val_split(DATASET_PATH);
train_dataset = read_train_dataset(TRAIN_DATASET_PATH, train_split);

 %f=figure;
 %g=figure;
 tic
for i=1: 1 %length(train_dataset) 
    windowCandidates = [];
 image = imread(train_dataset(i).image);
 image=rgb2gray(image);
 for temp=1:length(templates)
 for j=30:10:250
    re_template=imresize(templates{temp},j/250);
    %figure(g)
    %imshow(re_template);
   % pause(2)
  C = normxcorr2( re_template,image);
          if max(max(C)) > 0.8
            [~, peaks] = FastPeakFind(C);
            [ypeak,xpeak] = find(peaks);
            
            for n = 1:size(ypeak,1)
                if C(ypeak(n),xpeak(n))>0.7
                    yoffSet = ypeak(n)-size( re_template,1);
                    xoffSet = xpeak(n)-size( re_template,2);
                    if yoffSet < 0 || xoffSet < 0
                        break
                    end
                    windowCandidates=[windowCandidates; [xoffSet+1,yoffSet+1,size(re_template,2), size(re_template,1)]];
                end
            end
          end

 %figure(f)
  % imshow (C);
  % pause(2);
 end
 end
plot_results=1;
   if plot_results
        hAx  = axes;
        imshow(image,'Parent', hAx);
        for zz = 1:size(windowCandidates,1)
            r=imrect(hAx, [windowCandidates(zz,1).x, windowCandidates(zz,1).y, windowCandidates(zz,1).w, windowCandidates(zz,1).h]);
            setColor(r,'r');
        end
        pause(2)
        % out_file = strcat(output_dir,'/m',files(i).name,'.png');
        % print(out_file,'-dpng')
    end
end
toc
end

