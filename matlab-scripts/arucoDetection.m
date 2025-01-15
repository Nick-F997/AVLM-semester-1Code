clear;
clc;
close all;

%% Load gary images and augmented images
PATHGaryBasic = "../combinedPicsBasic";
PATHGaryComplex = "../combinedPicsChallenging";
PATHNickBasic = "/home/nick/Projects/University/AVLM/semester1/image-augmenter/outputs/arucoBasic";
PATHNickComplex = "/home/nick/Projects/University/AVLM/semester1/image-augmenter/outputs/arucoChallenging";

%% It was supposed to run all at the same time but I ended up doing provided images and then augmented images separately
PATHS = {PATHGaryBasic, PATHGaryComplex};

%% Variable for reading in Unix or Windows filepaths
windowsOrUnix = filesep;

%% Training/Validation Split function
trainingValidationSplit = 0.7;

%% Training variables
maxEpochs = 10;
batchSize = 8;

%% Learning rates
learningRates = [0.001, 0.0001, 0.00001, 0.01, 0.1];

%% Loop all paths
for j = 1:length(PATHS)
    %% load data
    pathname = sprintf("%s/BBData.mat", PATHS{j});
    %% Both .mat files were slightly different, so were handled differently.
    if strcmp(PATHS{j}, PATHGaryBasic) || strcmp(PATHS{j}, PATHGaryComplex)
        data = load(pathname).labelsGroundTruth;
        % Access the 'fileNames' column
        fileNamesColumn = data.fileNames;

        % Replace '\' with '/'
        fileNamesColumn = strrep(fileNamesColumn, '\', '/');

        % Update the table with the modified column
        data.fileNames = fileNamesColumn;

            % Check if 'bBox' is a cell array and convert to numeric matrix if needed
        if iscell(data.bBox)
            data.bBox = cell2mat(data.bBox);
        end
    else 
        data = load(pathname).BBData;
        data = struct2table(data);
    end

    %% split training and test data
    inds = randperm(height(data));
    indsTrain = inds(1:int32(trainingValidationSplit * height(data)));
    indsTest = inds(int32(trainingValidationSplit * height(data)) + 1:end);

    training_data = data(indsTrain, :);
    testing_data = data(indsTest, :);

    for i = 1:length(learningRates)

        %% Set up options
        options = trainingOptions('adam', ...
                    'Plots','training-progress',...
                    'ValidationData',testing_data, 'MiniBatchSize',batchSize, ...
                    'maxEpochs', maxEpochs, 'InitialLearnRate',learningRates(i));

        anet = alexnet;
        layers = anet.Layers;
        clear anet;

        %% Put AlexNet in detection mode
        layers(end-2) = fullyConnectedLayer(4, 'Name','bBox');
        layers(end-1) = [];
        layers(end) = regressionLayer("Name","Output");
        
        %% Train network
        tic;
        [trainednet, info] = trainNetwork(training_data, 'bBox', layers, options);
        elapsedTime = toc;
        test_prediction = predict(trainednet, testing_data);

        %% Get metrics 
        data_metrics = struct('LearningRate', learningRates(i), ...
                          'RMSE', info.FinalValidationRMSE, ...
                          'Path', PATHS{j},...
                          'Time', elapsedTime);
        
        data_metrics

        %% Save metrics
        filename = sprintf("%s/metrics_interation%d.mat",PATHS{j}, i);
        save(filename, "data_metrics");
    
        clear layers;
        clear trained_network;
    end
end