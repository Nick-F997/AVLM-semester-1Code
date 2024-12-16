%% Written on a POSIX compliant system
% If you are on windows, change windowsOrUnix to '\'!
% Requires images to be stored in a folder called "imageData" with 
% Subfolders retrieved from blackboard.
clear;
clc;
close all;

%% Variable for reading in Unix or Windows filepaths
windowsOrUnix = '/';

%% Image size
imageSize = 224;

%% Training/Validation Split function
trainingValidationSplit = 0.7;

%% Training variables
maxEpochs = 15;
learningRate = 0.0001;
batchSize = 8;

%% Number of output classes
numOutputs = 2;

%% Root strings
root_path = sprintf('..%simageData%s', windowsOrUnix, windowsOrUnix);
basic_imgs = sprintf('arucoBasic%s', windowsOrUnix);
challenging_imgs = sprintf('arucoChallengingSubdivided%s',windowsOrUnix);

%% Weights strings
weights_path = sprintf("..%sweights%s", windowsOrUnix, windowsOrUnix);
basic_weights = sprintf("%sbasic_weights.mat", weights_path);
complex_weights = sprintf("%scomplex_weights.mat", weights_path);
combined_weights = sprintf("%scombined_weights.mat", weights_path);

%% Get proper paths to images
basic_path = sprintf("%s%s", root_path, basic_imgs);
challenging_path = sprintf("%s%s", root_path, challenging_imgs);

%% Data store of basic images
dataStoreBasic = imageDatastore(basic_path,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[imageSize imageSize ...
                    ]),[1,1,3]));

%% Data store of distorted and noisy images
dataStoreChallenging = imageDatastore(challenging_path,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[imageSize imageSize]),[1,1,3]));

%% Data store of combined images
dataStoreCombined = imageDatastore([basic_path, challenging_path],...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[imageSize imageSize]),[1,1,3]));


%% Get different data sets and split them 
[training_data_basic, testing_data_basic] = splitEachLabel(dataStoreBasic, ...
                                        trainingValidationSplit, 'randomized');

[training_data_complex, testing_data_complex] = splitEachLabel(dataStoreChallenging, ...
                                        trainingValidationSplit, 'randomized');

[training_data_combined, testing_data_combined] = splitEachLabel(dataStoreCombined, ...
                                        trainingValidationSplit, 'randomized');

%% Bring in Alex net for basic layer
% anet = alexnet;
%% Create 3 separate layers (not sure if good idea)
% layers_complex = anet.Layers;
%% Unload AlexNet from memory
% clear anet;
anet = resnet101;
lgraph = anet.layerGraph;
lgraph = removeLayers(lgraph,'fc1000');
lgraph = removeLayers(lgraph,'prob');
lgraph = removeLayers(lgraph,'ClassificationLayer_predictions');
lgraph = addLayers(lgraph,fullyConnectedLayer(numOutputs,'Name','fc'));
lgraph = addLayers(lgraph,classificationLayer("Name",'output'));
lgraph = connectLayers(lgraph,'pool5','fc');
lgraph = connectLayers(lgraph,'fc','output');
%% Extract last two layers and create number of outputs


% analyzeNetwork(lgraph);

%% Options for training basic layer
options_combined = trainingOptions('sgdm', 'Plots','training-progress',...
'ValidationData',testing_data_complex, 'MiniBatchSize',batchSize, ...
'maxEpochs', maxEpochs, 'InitialLearnRate',learningRate);

%% Train the network
trained_network = trainNetwork(training_data_complex, lgraph, options_combined);

%% Save the network for later
% trained_struct = trained_network.saveobj;

%% save it to mat file
% save(complex_weights, "trained_struct", "options_combined");

clear layers_complex;
clear trained_struct;
clear trained_network;
