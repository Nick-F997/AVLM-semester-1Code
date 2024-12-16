%% Written on a POSIX compliant system
% If you are on windows, change windowsOrUnix to '\'!
% Requires images to be stored in a folder called "imageData" with 
% Subfolders retrieved from blackboard.
clear;
clc;
close all;

%% Variable for reading in Unix or Windows filepaths
windowsOrUnix = filesep;

PATH = '../imageData/arucoChallengingSubdivided';

%% Training/Validation Split function
trainingValidationSplit = 0.7;

%% Training variables
maxEpochs = 5;
learningRate = 0.0001;
batchSize = 16;

%% Number of output classes
numOutputs = 100;

% % % Root strings
% % root_path = sprintf('C:\Users\g3-atkinson\Desktop%s', windowsOrUnix);
% % basic_imgs = sprintf('arucoBasic - cut%s', windowsOrUnix);
% % challenging_imgs = sprintf('arucoChallenging - cut%s',windowsOrUnix);
% % 
% % % Weights strings
weights_path = sprintf("..%sweights%s", windowsOrUnix, windowsOrUnix);
% % basic_weights = sprintf("%sbasic_weights.mat", weights_path);
complex_weights = sprintf("%scomplex_weights.mat", weights_path);
% % combined_weights = sprintf("%scombined_weights.mat", weights_path);
% % 
% % % Get proper paths to images
% % basic_path = sprintf("%s%s", root_path, basic_imgs);
% % challenging_path = sprintf("%s%s", root_path, challenging_imgs);
% % 
% % % Data store of basic images
% % dataStoreBasic = imageDatastore(basic_path,...
% %                     'IncludeSubfolders',true,...
% %                     'LabelSource','foldernames', 'ReadFcn', ...
% %                     @(f) repmat(imresize(imread(f),[227 227]),[1,1,3]));
% % 
% Data store of distorted and noisy images
dataStoreChallenging = imageDatastore(PATH,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[227 227]),[1,1,3]));

% % %% Data store of combined images
% % dataStoreCombined = imageDatastore([basic_path, challenging_path],...
% %                     'IncludeSubfolders',true,...
% %                     'LabelSource','foldernames', 'ReadFcn', ...
% %                     @(f) repmat(imresize(imread(f),[227 227]),[1,1,3]));


%% Get different data sets and split them 
% % [training_data_basic, testing_data_basic] = splitEachLabel(dataStoreBasic, ...
% %                                         trainingValidationSplit, 'randomized');

[training_data, testing_data] = splitEachLabel(dataStoreChallenging, ...
                                        trainingValidationSplit, 'randomized');

% % [training_data_combined, testing_data_combined] = splitEachLabel(dataStoreCombined, ...
% %                                         trainingValidationSplit, 'randomized');

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