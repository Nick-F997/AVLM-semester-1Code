%% Written on a POSIX compliant system
% If you are on windows, change windowsOrUnix to '\'!
% Requires images to be stored in a folder called "imageData" with 
% Subfolders retrieved from blackboard.
clear;
clc;
close all;

%% Variable for reading in Unix or Windows filepaths
windowsOrUnix = filesep;

PATH = 'imageData/arucoChallenging';

%% Training/Validation Split function
trainingValidationSplit = 0.7;

%% Training variables
maxEpochs = 5;
batchSize = 128;

%% Number of output classes
numOutputs = 100;

%% Array of learning rates
learningRates = [0.001, 0.0001, 0.00001, 0.01, 0.1];


weights_path = sprintf("..%sweights%s", windowsOrUnix, windowsOrUnix);

complex_weights = sprintf("%scomplex_weights.mat", weights_path);

%% Get training/testing data
dataStoreChallenging = imageDatastore(PATH,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[227 227]),[1,1,3]));


%% Split training testing data
[training_data, testing_data] = splitEachLabel(dataStoreChallenging, ...
                                        trainingValidationSplit, 'randomized');

for i = 1:length(learningRates)
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
    options = trainingOptions('adam', ...
    'Plots','training-progress',...
    'ValidationData',testing_data, 'MiniBatchSize',batchSize, ...
    'maxEpochs', maxEpochs, 'InitialLearnRate',learningRates(i), ...
    OutputFcn=@(info)stopTraining(info,95.0));

    %% Train the network
    tic; % Starts stopwatch
    [trained_network, info] = trainNetwork(training_data, layers,options);
    elapsedTime = toc;
    test_prediction = classify(trained_network, testing_data);

    %% Get accuracy
    accuracy_array = test_prediction == testing_data.Labels;
    accuracy = mean(accuracy_array) * 100;

    %% Generate confusion matrix (unused in final report)
    [cmap,clabel] = confusionmat(testing_data.Labels,test_prediction);
    confusionchart(cmap, clabel);
    
    title(sprintf("Test Acuracy = %.2f%%", accuracy));

    %% resize confusion matrix
    x0 = 10;
    y0 = 10;
    width = 1920;
    height = 1080;
    set(gcf,'position',[x0,y0,width,height])

    conf_filename = sprintf("confusion_matrix%d.png", i);
    saveas(gcf, conf_filename);

    %% Calculate F-score
    % Calculate True Positives, False Positives, False Negatives
    TP = diag(cmap); % Diagonals are true positives
    FP = sum(cmap, 1)' - TP;
    FN = sum(cmap, 2) - TP;

    % Calculate Precision, Recall, and F-score for each class
    precision = TP ./ (TP + FP);
    recall = TP ./ (TP + FN);
    F1 = 2 * (precision .* recall) ./ (precision + recall);

    % Handle NaN values in F1 (if precision + recall is 0)
    F1(isnan(F1)) = 0;

    % Display the F1-score for each class
    disp('F1-score for each class:');
    disp(F1);

    % calculate the average F1-score
    averageF1 = mean(F1);
    disp('Average F1-score:');
    disp(averageF1);

    %% Create struct with metrics
    data_metrics = struct('LearningRate', learningRates(i), ...
                          'Accuracy', info.FinalValidationAccuracy, ...
                          'Time', elapsedTime, ...
                          'F1', F1, ...
                          'AverageF1', averageF1);
    data_metrics

    %% Save struct
    filename = sprintf("metrics_interation%d.mat", i);
    save(filename, "data_metrics");
    %% Save the network for later
    %trained_struct = trained_network.saveobj;

    %% save it to mat file
    %save(complex_weights, "trained_struct", "options");

    clear layers;
    %clear trained_struct;
    clear trained_network;
end