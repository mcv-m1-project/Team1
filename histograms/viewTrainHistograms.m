function viewTrainHistograms(mod)
%Visualize the existing histograms. 
%Input parameter mod to be '' for the original histograms or '_mod' for the
%modified version of the histograms (created with modifyHists)
close all

histAll = loadHistograms('joint', 'hsv',mod);

hist_individual = loadHistograms('in', 'hsv',mod);
histoABC = hist_individual{1};
histoDF = hist_individual{2};
histoE = hist_individual{3};

histAll = histoABC + histoE + histoDF;
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