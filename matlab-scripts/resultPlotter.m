clear;
clc;
close all;
%% Change this to the network name to pull in the data
Network = 'MobileNet';

%% Paths
PATHBasic = sprintf('../results/basicLearningRate%s', Network);
PATHComplex = sprintf('../results/complexLearningRate%s', Network);
PATHGraphs = sprintf('../results/%sGraphs', Network);
numStructs = 5;

PATHs = {PATHBasic, PATHComplex};

%% Arrays for data 
basicLearningRates = [];
complexLearningRates = [];
basicTimeElapsed = [];
complexTimeElapsed = [];
basicAccuracy = [];
complexAccuracy = [];
basicFscore = [];
complexFscore = [];

%% Get the data from training
for i = 1:length(PATHs)
   for j = 1:numStructs
        filepath = sprintf("%s/metrics_interation%d.mat", PATHs{i}, j);
        if i == 1
            s = load(filepath).data_metrics;
            basicLearningRates(end + 1) = s.LearningRate;
            basicTimeElapsed(end + 1) = s.Time;
            basicAccuracy(end + 1) = s.Accuracy;
            basicFscore(end + 1) = s.AverageF1;
        else
            s = load(filepath).data_metrics;
            complexLearningRates(end + 1) = s.LearningRate;
            complexTimeElapsed(end + 1) = s.Time;
            complexAccuracy(end + 1) = s.Accuracy;
            complexFscore(end + 1) = s.AverageF1;
        end
   end
end

%% Sort data
[basicSorted, order] = sort(basicLearningRates);
basicTimeElapsed = basicTimeElapsed(order);
basicFscore = basicFscore(order);
basicAccuracy = basicAccuracy(order);

[complexSorted, order] = sort(complexLearningRates);
complexTimeElapsed = complexTimeElapsed(order);
complexFscore = complexFscore(order);
complexAccuracy = complexAccuracy(order);

%% Plot time elapsed
semilogx(basicSorted, basicTimeElapsed, 'o','MarkerFaceColor',[0 0.447 0.741])
hold on
semilogx(basicSorted, basicTimeElapsed, 'Color', [0 0.447 0.741])
semilogx(complexSorted, complexTimeElapsed, 'o','MarkerFaceColor',[0.741 0 0])
semilogx(complexSorted, complexTimeElapsed, 'Color', [0.741 0 0])

grid on
legend('Basic Dataset', '','Complex Dataset','')

tit = sprintf('%s Training Time at Each Learning Rate', Network);
title(tit)
xlabel('Learning Rate (log)')
ylabel('Time (seconds)')

filename = sprintf("%s/timeElapsed.png", PATHGraphs);
saveas(gcf, filename);
close all;

%% Plot accuracy
semilogx(basicSorted, basicAccuracy, 'o','MarkerFaceColor',[0 0.447 0.741])
hold on
semilogx(basicSorted, basicAccuracy, 'Color', [0 0.447 0.741])
semilogx(complexSorted, complexAccuracy, 'o','MarkerFaceColor',[0.741 0 0])
semilogx(complexSorted, complexAccuracy, 'Color', [0.741 0 0])

grid on
legend('Basic Dataset','' ,'Complex Dataset','')
tit = sprintf('%s Final Validation Accuracy at Each Learning Rate', Network);
title(tit)
xlabel('Learning Rate (log)')
ylabel('Final Validation Accuracy (%)')

filename = sprintf("%s/accuracy.png", PATHGraphs);
saveas(gcf, filename)
close all;

%% Plot F-score
semilogx(basicSorted, basicFscore, 'o','MarkerFaceColor',[0 0.447 0.741])
hold on
semilogx(basicSorted, basicFscore, 'Color', [0 0.447 0.741])
semilogx(complexSorted, complexFscore, 'o','MarkerFaceColor',[0.741 0 0])
semilogx(complexSorted, complexFscore, 'Color', [0.741 0 0])

grid on
legend('Basic Dataset','' ,'Complex Dataset','')
tit = sprintf('%s Average F-score at Each Learning Rate', Network);
title(tit)
xlabel('Learning Rate (log)')
ylabel('Average F-score')

filename = sprintf("%s/fscore.png", PATHGraphs);
saveas(gcf, filename)
close all;
