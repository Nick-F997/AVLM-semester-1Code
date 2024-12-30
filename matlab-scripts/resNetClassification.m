%% Written on a POSIX compliant system
% If you are on windows, change windowsOrUnix to '\'!
% Requires images to be stored in a folder called "imageData" with 
% Subfolders retrieved from blackboard.
clear;
clc;
close all;

%% Variable for reading in Unix or Windows filepaths
windowsOrUnix = filesep;

PATH = 'imageData/arucoBasicSub';

%% Training/Validation Split function
trainingValidationSplit = 0.7;

%% Training variables
maxEpochs = 5;
learningRate = 0.0001;
batchSize = 4;

imgSize = 224;

%% Number of output classes
numOutputs = 5;

weights_path = sprintf("weights%s", windowsOrUnix);

weights = sprintf("%sbasic_weights_resnet.mat", weights_path);

dataStoreChallenging = imageDatastore(PATH,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[imgSize imgSize]),[1,1,3]));


[training_data, testing_data] = splitEachLabel(dataStoreChallenging, ...
                                        trainingValidationSplit, 'randomized');

%% Bring in Alex net for basic layer
anet = resnet101;
lgraph = anet.layerGraph;
lgraph = removeLayers(lgraph,'fc1000');
lgraph = removeLayers(lgraph,'ClassificationLayer_predictions');
lgraph = addLayers(lgraph,fullyConnectedLayer(numOutputs,'Name','fc'));
lgraph = addLayers(lgraph,classificationLayer("Name",'output'));
lgraph = connectLayers(lgraph,'pool5','fc');
lgraph = connectLayers(lgraph,'fc','prob');
lgraph = connectLayers(lgraph,'prob','output');


%% Options for training basic layer
options = trainingOptions('sgdm', 'Plots','training-progress',...
'ValidationData',testing_data, 'MiniBatchSize',batchSize,...
'maxEpochs', maxEpochs, 'InitialLearnRate',learningRate, 'Shuffle','every-epoch');

%% Train the network
trained_network = trainNetwork(training_data, lgraph, options);

%% Save the network for later
trained_struct = trained_network.saveobj;

%% save it to mat file
save(weights, "trained_struct", "options");

clear layers;
clear trained_struct;
clear trained_network;