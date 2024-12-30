%% Written on a POSIX compliant system
% If you are on windows, change windowsOrUnix to '\'!
% Requires images to be stored in a folder called "imageData" with 
% Subfolders retrieved from blackboard.
clear;
clc;
close all;

%% Variable for reading in Unix or Windows filepaths
windowsOrUnix = filesep;

PATH = 'imageData/arucoChallengingSubdivided';

%% Training/Validation Split function
trainingValidationSplit = 0.7;

%% Training variables
maxEpochs = 5;
learningRate = 0.0001;
batchSize = 16;

%% Number of output classes
numOutputs = 100;

weights_path = sprintf("..%sweights%s", windowsOrUnix, windowsOrUnix);

complex_weights = sprintf("%scomplex_weights.mat", weights_path);

dataStoreChallenging = imageDatastore(PATH,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[227 227]),[1,1,3]));



[training_data, testing_data] = splitEachLabel(dataStoreChallenging, ...
                                        trainingValidationSplit, 'randomized');

%% Bring in Alex net for basic layer
anet = alexnet;
%% Create 3 separate layers (not sure if good idea)
layers = anet.Layers;
%% Unload AlexNet from memory
clear anet;

%% Extract last two layers and create number of outputs
layers(end-2) = fullyConnectedLayer(numOutputs, 'Name', 'fc8');
layers(end) = classificationLayer("Name",'output');

%% Options for training basic layer
options = trainingOptions('sgdm', 'Plots','training-progress',...
'ValidationData',testing_data, 'MiniBatchSize',batchSize, ...
'maxEpochs', maxEpochs, 'InitialLearnRate',learningRate);

%% Train the network
trained_network = trainNetwork(training_data, layers, options);

%% Save the network for later
trained_struct = trained_network.saveobj;

%% save it to mat file
save(complex_weights, "trained_struct", "options");

clear layers;
clear trained_struct;
clear trained_network;