function FM= testHistogramBins

%Set TestBins to true if you want to test the system for histograms with
%different number of bins.
%Set TestBins to false if you want to test the system for different
%percentages of deleted low-saturated colors (grays), reds or blues
TestBins = false;

if TestBins == true
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%TEST NBINS OF HISTOGRAM%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    perc = 0.25;
    
    for Nbins = 60:10:160
        
        %Compute a HS histogram of the train split of the dataset with
        %NbinsxNbins and a percentage of deleted grays of 25%
        [~,~,~, histAll] = calculateTrainHists('hsv',Nbins,perc,true);
        
        %For each histogram NbinsxNbins, calculate the performance of the system.
        %This function will return some evaluation parameters, as well as the
        %threshold that provided these results (the best obtained after testing
        %with thresholds from 0:0.1:1, and the time elapsed in all this computation.
        [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,...
            Fmeasure, threshold, time] = calculatePerformance(histAll,Nbins,'val');
        
        %Plot results
        fprintf('Nbins: %d\n', Nbins)
        fprintf('Percentage deleted grays: %f\n', perc)
        fprintf('Threshold: %d\n', threshold)
        fprintf('Precision: %f\n', pixelPrecision)
        fprintf('Recall: %f\n', pixelSensitivity)
        fprintf('F measure: %f\n', Fmeasure)
        fprintf('Pixel accuracy: %f\n', pixelAccuracy)
        fprintf('Pixel specificity: %f\n', pixelSpecificity)
        fprintf('Time elapsed in calculatePerformance: %f\n\n', time)
        
    end
    
    
else
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%TEST PERCENTAGE OF DELETED BINS%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Nbins = 64;
    perc =0;
    Fmeasure_max=0;
    pixelPrecision_max=0; pixelAccuracy_max=0; pixelSpecificity_max=0; pixelSensitivity_max=0;
    F=[];
    %Compute a HS histogram of the train split of the dataset with
    %64x64 bins and no deleted grays
    [histoABC,histoDF,histoE] = calculateTrainHists('hsv',Nbins,perc,false);
    
    perc = 0.1;
    %Change the values in the for loop to evaluate different configurations
    % 0-percR1 Hue values will be preserved
    % percR2-100% Hue values will be preserved
    percR1 = 10;
    percR2 = 55;
    for percR1 = 10
        
        histoABC_ = histoABC;
        histoDF_ = histoDF;
        histoE_ = histoE;
        
        % %Eliminate a 'perc' percentage of the low-saturated values
        histoABC_(:,1:round(perc*Nbins))=0;
        histoDF_(:,1:round(perc*Nbins))=0;
        histoE_(:,1:round(perc*Nbins))=0;
        
        %Eliminate non-red (8%-85%)or non-blue(0-55%,65%-100) values
        histoABC_(percR1:percR2,:)=0;
        
        histoDF_(1:round(0.55*Nbins),:)=0;
        histoDF_(round(0.65*Nbins):Nbins,:)=0;
        
        %Eliminate non-red or non-blue values(8%-55%,65%-85%)
        histoE_(percR1:round(0.55*Nbins),:)=0;
        histoE_(round(0.65*Nbins):percR2,:)=0;
        
        histAll = histoABC_+histoDF_+histoE_;
        
        %For each histogram percentage, calculate the performance of the system.
        %This function will return some evaluation parameters, as well as the
        %threshold that provided these results (the best obtained after testing
        %with thresholds from 0:0.1:1, and the time elapsed in all this computation.
        [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,...
            Fmeasure, threshold, time,FM] = calculatePerformance(histAll,Nbins,'val');
        
        
        
        %Plot results
        fprintf('Nbins: %d\n', Nbins)
        fprintf('Percentage deleted grays: %f\n', perc)
        fprintf('Percentage R1: %f\n', percR1)
        fprintf('Percentage R2: %f\n', percR2)
        fprintf('Threshold: %d\n', threshold)
        fprintf('Precision: %f\n', pixelPrecision)
        fprintf('Recall: %f\n', pixelSensitivity)
        fprintf('F measure: %f\n', Fmeasure)
        fprintf('Pixel accuracy: %f\n', pixelAccuracy)
        fprintf('Pixel specificity: %f\n', pixelSpecificity)
        fprintf('Time elapsed in calculatePerformance: %f\n\n', time)
        
        
        
        
        percR1 = 10;
    end
%     for percR2 = 56:2:64
%         
%         histoABC_ = histoABC;
%         histoDF_ = histoDF;
%         histoE_ = histoE;
%         
%         % %Eliminate a 'perc' percentage of the low-saturated values
%         histoABC_(:,1:round(perc*Nbins))=0;
%         histoDF_(:,1:round(perc*Nbins))=0;
%         histoE_(:,1:round(perc*Nbins))=0;
%         
%         %Eliminate non-red (8%-85%)or non-blue(0-55%,65%-100) values
%         histoABC_(percR1:percR2,:)=0;
%         
%         histoDF_(1:round(0.55*Nbins),:)=0;
%         histoDF_(round(0.65*Nbins):Nbins,:)=0;
%         
%         %Eliminate non-red or non-blue values(8%-55%,65%-85%)
%         histoE_(percR1:round(0.55*Nbins),:)=0;
%         histoE_(round(0.65*Nbins):percR2,:)=0;
%         
%         histAll = histoABC_+histoDF_+histoE_;
%         
%         %For each histogram percentage, calculate the performance of the system.
%         %This function will return some evaluation parameters, as well as the
%         %threshold that provided these results (the best obtained after testing
%         %with thresholds from 0:0.1:1, and the time elapsed in all this computation.
%         [pixelPrecision, pixelAccuracy, pixelSpecificity, pixelSensitivity,...
%             Fmeasure, threshold, time] = calculatePerformance(histAll,Nbins,'val');
%         
%         
%         
%         %Plot results
%         fprintf('Nbins: %d\n', Nbins)
%         fprintf('Percentage deleted grays: %f\n', perc)
%         fprintf('Percentage R1: %f\n', percR1)
%         fprintf('Percentage R2: %f\n', percR2)
%         fprintf('Threshold: %d\n', threshold)
%         fprintf('Precision: %f\n', pixelPrecision)
%         fprintf('Recall: %f\n', pixelSensitivity)
%         fprintf('F measure: %f\n', Fmeasure)
%         fprintf('Pixel accuracy: %f\n', pixelAccuracy)
%         fprintf('Pixel specificity: %f\n', pixelSpecificity)
%         fprintf('Time elapsed in calculatePerformance: %f\n\n', time)
%         
%         
%         
%         F = [F Fmeasure];
%     end
    
end
end
