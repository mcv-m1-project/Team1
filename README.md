# Team1 - Week 3

## Execution instructions

Place the provided training and testing datasets inside a folder named
**DataSetDelivered** in the root of the project, so that the training dataset can be found at
`./DataSetDelivered/train` and the test dataset at
`./DataSetDelivered/test`.

- **Analyze Dataset**

Run the `AnalyzeDataset.m` script. By default it analyzes the whole dataset (train + validation split), but you can analyze a particular split by changing the `FULL_TRAIN_VAL_OPTION` variable inside the script. The signals that don't have any pixel set to '1' inside their bounding box are not used for the analysis.

Bear in mind that an already computed train-validation split is needed for these cases to run, so you should run first `TrainValSplit.m`.

- **Split the dataset into training and validation sets**

First you should select the proportion of training and validation sets sizes by changing the `TRAIN_PERCENTAGE` variable inside the `TrainValSplit.m` script to the appropriate number (e.g. if you want a 70% train - 30% validation split, you should assign 70 to this variable).

Then you just run the `TrainValSplit.m` script to compute and store the dataset split.

Note that this computation is not deterministic, as it involves random permutations and a clustering algorithm with random initializations, so don't expect it to produce the same result for the same `TRAIN_PERCENTAGE` value.

- **Compute masks for any input**

Run the `TrafficSignDetection_test` function with the necessary input arguments. For example `TrafficSignDetection_test('DataSetDelivered/test','test','hsv','convolution','', 0)`. The created masks will be stored in the specified output directory ('test' in the example).

| Parameter name | Possible value/s | Description |
| :---: | :---: |  :---: |
| input_dir | Path | Directory where the test images to analize (.jpg) reside
| output_dir | Path | Directory where the masks and bounding boxes will be stored |
| segm_method | 'mean_shift', 'ucm' | Region-based color segmentation method |
| pixel_method | 'hsv', 'hsv_thr', 'normrgb | Pixe-based color segmentation method |
| window_method | 'ccl', 'naive_window', 'integral_window', 'correlation', 'template_matching', 'template_corr', 'hough' | Window candidate generation method |
| plot_results | 0, 1 | Whether to interactively plot the results or not | 

- **Performance evaluation**

  - `TrafficSignDetection`: evaluates the default performance of the system in terms of **precision**, **accuracy**, **specificity** and **sensitivity** pixel values over the train ('train') or validation ('val') splits.

  - `ThresholdEvalCurve`: evaluates the performance in terms of accuracy, specificity, sensitivity, precision and F1 measure over the specified range of threshold values applied to the color segmentation decision function.

  - `MorphEvalCurve`: given a morphological filtering method (1 or 2), it evaluates the performance in terms of accuracy, specificity, sensitivity, precision and F1 measure over the specified range of object sizes for the morphological area opening applied in the morphological filtering stage that comes after the color segmentation stage.

- **Other functions**
 - `calculateTrainHists(colorsp)`: where colorsp can be 'hsv' or 'ycrcb'. Set the saveHist and/or plotHist variables to true if you want to store/view the created histograms.

 - `viewTrainHistograms()`: visualize the available histograms. The input argument should be '' for the original histograms or '\_mod' for the modified version of the histograms.

 - `modifyHist()`: change the code at your will to modify the histograms (eliminate low-saturated values for example).



 *NOTE: If an error is raised when executing TrafficSignDetection or TrafficSignDetection_test, please run the TrainValSplit script, as it is an error in the format of the file depending on the Operating System.*
