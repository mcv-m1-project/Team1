function modifyHists()
%As there are a lot of possible modifications to a histogram, this is not a
%automatic function that modifies a histogram with the input parameters.
%To make a modification, change the code of this function at your will.

save = false;
plotHist = true;

histAll = loadHistograms('joint', 'hsv','');

hist_individual = loadHistograms('', 'hsv','');
histoABC = hist_individual{1};
histoDF = hist_individual{1};
histoE = hist_individual{1};

%Parameters
max_c1


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
    bar3(pdf_normalize)
    xlabel('1st comp'); ylabel('2nd comp');
    set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
    
end


end