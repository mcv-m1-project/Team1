# Team1

## Execution instructions

Place the provided training and testing datasets inside a folder named
**DataSetDelivered**, so that the training dataset can be found at
`./DataSetDelivered/train` and the testing dataset at
`./DataSetDelivered/test`.

- **Analyze Dataset**

Run the `AnalyzeDataset.m` script. By default it analyzes the whole dataset (train + validation split), but you can analyze a particular split by changing the `FULL_TRAIN_VAL_OPTION` variable inside the script. The signals that don't have any pixel set to '1' inside their bounding box are not used for the analysis.

Bear in mind that an already computed train-validation split is needed for these cases to run, so you should run first `TrainValSplit.m`.

- **Split the dataset into training and validation sets**

First you should select the proportion of training and validation sets sizes by changing the `TRAIN_PERCENTAGE` variable inside the `TrainValSplit.m` script to the appropriate number (e.g. if you want a 70% train - 30% validation split, you should assign 70 to this variable).

Then you just run the `TrainValSplit.m` script to compute and store the dataset split.

Note that this computation is not deterministic, as it involves random permutations and a clustering algorithm with random initializations, so don't expect it to produce the same result for the same `TRAIN_PERCENTAGE` value.

- **Computing masks for test set**

Run the TrafficSignDetection_test script with the necessary input arguments. For example TrafficSignDetection_test('DataSetDelivered/test','test','hsv','',''). The created masks will be stored in the output directory ('test' in the example).

- **Other functions**
 - calculateTrainHists(colorsp): where colorsp can be 'hsv' or 'ycrcb'. Set the saveHist and/or plotHist variables to true if you want to store/view the created histograms.
 - viewTrainHistograms(): visualize the available histograms. The input argument should be '' for the original histograms or '\_mod' for the modified version of the histograms.
 - modifyHist(): change the code at your will to modify the histograms (eliminate low-saturated values for example).
