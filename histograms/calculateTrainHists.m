function [histoABC,histoDF,histoE,histAll,cntR,cntB,cntRB] = calculateTrainHists(colorsp,Nbins,perc,deletegrays)
close all
DATASET_PATH = 'DataSetDelivered';
%READ DATASET
TRAIN_DATASET_PATH = fullfile(DATASET_PATH, 'train');
% Get the train dataset
[train_split, ~] = read_train_val_split(DATASET_PATH);
train_dataset = read_train_dataset(TRAIN_DATASET_PATH, train_split);

saveHist = true;
plotHist = true;

masked_comp_ABC=[];
masked_comp_DF=[];
masked_comp_E=[];
masked_comp_total=[];

masked_comp2_ABC=[];
masked_comp2_DF=[];
masked_comp2_E=[];
masked_comp2_total=[];

cntR = 0;
cntB = 0;
cntRB = 0;

for i=1: size(train_dataset,2)
    %read image and mask
    im=imread(train_dataset(i).image);
    mask=imread(train_dataset(i).mask);
    
    %convert to desired color space
    if strcmp(colorsp,'hsv')
        im_cs=rgb2hsv(im);
        %%take the hue and saturation in the new color space
        comp=im_cs(:,:,1);
        comp2=im_cs(:,:,2);
    elseif strcmp(colorsp,'ycrcb')
        im_cs = rgb2ycbcr(im);
        %take the 2 components of the chroma in the new color space
        comp=im_cs(:,:,2);
        comp2=im_cs(:,:,3);
    end
    
    %parse annotations to get signal type
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    mask=imread(train_dataset(i).mask);
    %For every signal in the image, save the non-zero values 
    for it=1:num_elems 
        if nnz(mask) == 0
            continue
        end
        if type{it}==1 || type{it}==2 || type{it}==3
            masked_comp_ABC=[masked_comp_ABC, comp(logical(mask))'];
            masked_comp2_ABC=[masked_comp2_ABC, comp2(logical(mask))'];
            cntR = cntR+1;
            
        elseif  type{it}==4 || type{it}==6
            masked_comp_DF=[masked_comp_DF, comp(logical(mask))'];
            masked_comp2_DF=[masked_comp2_DF, comp2(logical(mask))'];
            cntB = cntB+1;
        elseif  type{it}==5
            masked_comp_E=[masked_comp_E, comp(logical(mask))'];
            masked_comp2_E=[masked_comp2_E, comp2(logical(mask))'];
            cntRB = cntRB+1;
        end
        
        masked_comp_total=[masked_comp_total, comp(logical(mask))'];
        masked_comp2_total=[masked_comp2_total, comp2(logical(mask))'];
        
    end
end


if strcmp(colorsp,'hsv')
    %n for HSV
    n1=0:1/(Nbins-1):1;
    n2=0:1/(Nbins-1):1;
elseif strcmp(colorsp,'ycrcb')
    %n for YCRCB
    n1=0:3.5:240;
    n2=0:3.5:240;
end

%Define the edges of the bins in the histograms
edges = {n1; n2};

%calculate the histogram with the 2 first components
histoABC= hist3([masked_comp_ABC',masked_comp2_ABC'],'Edges', edges);
histoDF= hist3([masked_comp_DF',masked_comp2_DF'],'Edges', edges);
histoE= hist3([masked_comp_E',masked_comp2_E'],'Edges', edges);

if deletegrays == true
    % %Eliminate low-saturated values (25%)
    histoABC(:,1:round(perc*Nbins))=0;
    histoDF(:,1:round(perc*Nbins))=0;
    histoE(:,1:round(perc*Nbins))=0;

    %Eliminate non-red (8%-85%)or non-blue(0-55%,65%-100) values
    histoABC(round(0.08*Nbins):round(0.85*Nbins),:)=0;

    histoDF(1:round(0.55*Nbins),:)=0;
    histoDF(round(0.65*Nbins):Nbins,:)=0;

    %Eliminate non-red or non-blue values(8%-55%,65%-85%) 
    histoE(round(0.08*Nbins):1:round(0.55*Nbins),:)=0;
    histoE(round(0.65*Nbins):round(0.85*Nbins),:)=0;

end

histoABC = histoABC / cntR;
histoDF = histoDF / cntB;
histoE = histoE / cntRB;

histAll = histoABC+histoDF+histoE;

%pdf=hist3([masked_comp_total' , masked_comp2_total'],'Edges',edges);

if saveHist

    %store histograms
    save(['DataSetDelivered/histogram_', colorsp, '.mat'],'histAll');
    %save(['DataSetDelivered/HistABC_', colorsp, '.mat'],'histoABC');
    %save(['DataSetDelivered/HistDF_', colorsp, '.mat'],'histoDF');
    %save(['DataSetDelivered/HistE_', colorsp, '.mat'],'histoE');

end

if plotHist
    %plot histograms
    figure('name', 'signal type A, B & C');
    bar3(histoABC);
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'signal type D & F');
    bar3(histoDF);
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'signal type E');
    bar3(histoE);
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'All signal types');
    bar3(histAll)
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
end


end
