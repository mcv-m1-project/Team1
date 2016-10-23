function  hist_merge

%Load histograms
histograms = loadHistograms('', 'hsv','_mod');

histoABC = histograms{1};
histoDF = histograms{2};
histoE = histograms{3};

%For the bins in histoDF where there is a value ~=0, how many bins in the
%histoABC also have a value ~=0? In order to merge them, it should be 0.
%To simplify, how many bins have a value in both ABC & DF? If there were,
%they might be low-saturated values that we would want to eliminate first
if nnz(histoABC(histoDF ~= 0))==0
    histJoint = histoABC + histoDF;
    bar3(histJoint)
else 
    error('Histograms could not be safely merged')
end

%Add the histogram for type E signals too
histAll = histJoint + histoE;
figure()
bar3(histAll)

save(['DataSetDelivered/histogram_hsv', '.mat'],'histAll');


end