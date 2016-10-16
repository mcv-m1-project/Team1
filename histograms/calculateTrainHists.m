function calculateTrainHists(colorsp)
%colorsp= 'lab','hsv'

DATASET_PATH = 'DataSetDelivered';
%READ DATASET
TRAIN_DATASET_PATH = fullfile(DATASET_PATH, 'train');
% Get the train dataset
[train_split, ~] = read_train_val_split(DATASET_PATH);
train_dataset = read_train_dataset(TRAIN_DATASET_PATH, train_split);

saveHist = false;
plotHist = true;

masked_comp_ABC=[];
masked_comp_DF=[];
masked_comp_E=[];
masked_comp_total=[];

masked_comp2_ABC=[];
masked_comp2_DF=[];
masked_comp2_E=[];
masked_comp2_total=[];


for i=1: size(train_dataset,2)
    %read image and mask
    im=imread(train_dataset(i).image);
    mask=imread(train_dataset(i).mask);
    
    %convert to desired color space
    if strcmp(colorsp,'hsv')
        im_cs=rgb2hsv(im);
    elseif strcmp(colorsp,'lab')
        im_cs=colorspace('Lab-<',im);
        min_c2 = 0.1;
        min_c3 = 0.1;
    end
    %take the first 2 components of the image in the new color space
    comp=im_cs(:,:,1);
    comp2=im_cs(:,:,2);
    
    %parse annotations to get signal type
    [bound_box, type, num_elems] = parse_annotations(train_dataset(i).annotations);
    
    %For every signal in the image, save the non-zero values 
    for it=1:num_elems 
        if nnz(mask) == 0
            continue
        end
        if type{it}==1 || type{it}==2 || type{it}==3
            masked_comp_ABC=[masked_comp_ABC, comp(logical(mask))'];
            masked_comp2_ABC=[masked_comp2_ABC, comp2(logical(mask))'];
            
        elseif  type{it}==4 || type{it}==6
            masked_comp_DF=[masked_comp_DF, comp(logical(mask))'];
            masked_comp2_DF=[masked_comp2_DF, comp2(logical(mask))'];
        elseif  type{it}==5
            masked_comp_E=[masked_comp_E, comp(logical(mask))'];
            masked_comp2_E=[masked_comp2_E, comp2(logical(mask))'];
        end
        
        masked_comp_total=[masked_comp_total, comp(logical(mask))'];
        masked_comp2_total=[masked_comp2_total, comp2(logical(mask))'];
        
    end
end


if strcmp(colorsp,'hsv')
    %n for HSV
    n1=0:1/63:1;
    n2=0:1/63:1;
elseif strcmp(colorsp,'lab')
    %n for LAB
    n1=-127:2:127;
    n2=-127:2:127;
end

%Define the edges of the bins in the histograms
edges = {n1; n2};

%calculate the histogram with the 2 first components
histoABC= hist3([masked_comp_ABC',masked_comp2_ABC'],'Edges', edges);
histoABC=histoABC/max(max(histoABC));

histoDF= hist3([masked_comp_DF',masked_comp2_DF'],'Edges', edges);
histoDF=histoDF/max(max(histoDF));

histoE= hist3([masked_comp_E',masked_comp2_E'],'Edges', edges);
histoE=histoE/max(max(histoE));


pdf=hist3([masked_comp_total' , masked_comp2_total'],'Edges',edges);
pdf_normalize = (pdf./ max(max(pdf)));% pdf normalization

if saveHist
    %store normalized histograms
    save(['DataSetDelivered/HistALL_', colorsp, '.mat'],'pdf');
    save(['DataSetDelivered/HistABC_', colorsp, '.mat'],'histoABC');
    save(['DataSetDelivered/HistDF_', colorsp, '.mat'],'histoDF');
    save(['DataSetDelivered/HistE_', colorsp, '.mat'],'histoE');
end

if plotHist
    %plot normalized histograms
    figure('name', 'signal type A, B & C');
    bar3(histoABC)
    xlabel('1st comp'); ylabel('2nd comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'signal type D & F');
    bar3(histoDF)
    xlabel('1st comp'); ylabel('2nd comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'signal type E');
    bar3(histoE)
    xlabel('1st comp'); ylabel('2nd comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'All signal types');
    bar3(pdf)
    xlabel('1st comp'); ylabel('2nd comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
end


end
