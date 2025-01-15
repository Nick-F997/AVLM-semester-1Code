# UFMFTT-30-3 AVLM Semester 1 assessment code
This code was submitted alongside my report, and aims to analyse the effect of learning rate on training CNNs. 

The following is a list of files (all within `matlab-scripts/` and their functions):
**Classification Networks**
* `alexNetClassification.m` - The file used to train AlexNet.
* `GoogleNetClassification.m` - the file used to train GoogleNet.
* `MobileNetClassification.m` - the file used to train MobileNet.
* `resultPlotter.m` - used to plot the results of individual network metrics.
* `resultPlotter_averaged.m` - used to plot averages of all 3 network metrics. 
* `stopTraining.m` - a function to stop training when a certain threshold is met.
**Detection Networks**
* `arucoDetection.m` - the file used to train alexnet as a detection network.
* `resultPlotter_detection.m` - the file used to graph detection network metrics.

Additionally, the image augmentation code has been included in the directory `image-augmenter/`. This is written in Python, and requires `Pillow` and `scipy` to be installed in either a virtual python environment or your root python install. It requires that you call it with the following:
```python
python3 scripts/main.py <path to imageData/ directory> <path to an output directory>
```
I would recommend using an absolute path, it was thrown together in a hurry and could break something! 