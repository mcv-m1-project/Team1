function modifyHists()
%As there are a lot of possible modifications to a histogram, this is not a
%automatic function that modifies a histogram with the input parameters.
%To make a modification, change the code of this function at your will.
close all
saveHist = true;
plotHist = true;
colorspace = 'hsv';

histAll = loadHistograms('joint', colorspace,'');

hist_individual = loadHistograms('', colorspace,'');
histoABC = hist_individual{1};
histoDF = hist_individual{2};
histoE = hist_individual{3};

%% CHANGES
histoABC(:,1:20)=0;
histoABC(10:60,:)=0;

histoDF(:,1:20)=0;
histoDF(1:20,:)=0;
histoDF(55:64,:)=0;

histoE(:,1:20)=0;
histoE(10:20,:)=0;
histoE(55:60,:)=0;

histAll(:,1:20)=0;
histAll(10:20,:)=0;
histAll(55:60,:)=0;

%%
if saveHist
    %store histograms
    save(['DataSetDelivered/HistALL_',colorspace,'_mod.mat'],'histAll');
    save(['DataSetDelivered/HistABC_',colorspace,'_mod.mat'],'histoABC');
    save(['DataSetDelivered/HistDF_',colorspace,'_mod.mat'],'histoDF');
    save(['DataSetDelivered/HistE_',colorspace,'_mod.mat'],'histoE');
end


if plotHist
    %plot normalized histograms
    figure('name', 'signal type A, B & C');
    bar3(histoABC)
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'signal type D & F');
    bar3(histoDF)
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'signal type E');
    bar3(histoE)
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
    figure('name', 'All signal types');
    bar3(histAll)
    xlabel('2nd comp'); ylabel('1st comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
end


end