function viewTrainHistograms()

histAll = loadHistograms('joint', 'hsv','');
hist_individual = loadHistograms('', 'hsv','');

figure('name', 'All signs histogram normalized');
assignin('base', 'histAll', histAll);
bar3(histAll)



end