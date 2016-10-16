function viewTrainHistograms()
close all

histAll = loadHistograms('joint', 'hsv','');

hist_individual = loadHistograms('in', 'hsv','');
histoABC = hist_individual{1};
histoDF = hist_individual{2};
histoE = hist_individual{3};

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