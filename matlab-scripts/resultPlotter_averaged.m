clear all;
clc;

%% Output path
PATHGraphs = '../results/combinedResults';

%% network names
alexNet = 'AlexNet';
googleNet = 'GoogleNet';
mobileNet = 'MobileNet';
Networks = {alexNet, googleNet, mobileNet};

%% arrays for data
alexLearningRates = [];
googleLearningRates = [];
mobileLearningRates = [];

googleAverageTime = [];
alexAverageTime = [];
mobileAverageTime = [];

googleAverageF = [];
alexAverageF = [];
mobileAverageF = [];

googleAverageAcc = [];
alexAverageAcc = [];
mobileAverageAcc = [];

%% Loop all networks and pull in their data
for ii = 1:length(Networks)
    PATHBasic = sprintf('../results/basicLearningRate%s', Networks{ii});
    PATHComplex = sprintf('../results/complexLearningRate%s', Networks{ii});
    for jj = 1:5
        % Excuse crap spelling of "iteration"
        basic_filepath = sprintf("%s/metrics_interation%d.mat", PATHBasic, jj);
        complex_filepath = sprintf("%s/metrics_interation%d.mat", PATHComplex, jj);
        
        basic_data = load(basic_filepath).data_metrics;
        complex_data = load(complex_filepath).data_metrics;

        %% Stick data in correct bins
        if strcmp(Networks{ii}, alexNet)
            alexLearningRates(end + 1) = basic_data.LearningRate;
            alexAverageTime(end + 1) = mean([basic_data.Time, complex_data.Time]);
            alexAverageAcc(end + 1) = mean([basic_data.Accuracy, complex_data.Accuracy]);
            alexAverageF(end + 1) = mean([basic_data.AverageF1, complex_data.AverageF1]);
        end
        if strcmp(Networks{ii}, googleNet)
            googleLearningRates(end + 1) = basic_data.LearningRate;
            googleAverageTime(end + 1) = mean([basic_data.Time, complex_data.Time]);
            googleAverageAcc(end + 1) = mean([basic_data.Accuracy, complex_data.Accuracy]);
            googleAverageF(end + 1) = mean([basic_data.AverageF1, complex_data.AverageF1]);
        end
        if strcmp(Networks{ii}, mobileNet)
            mobileLearningRates(end + 1) = basic_data.LearningRate;
            mobileAverageTime(end + 1) = mean([basic_data.Time, complex_data.Time]);
            mobileAverageAcc(end + 1) = mean([basic_data.Accuracy, complex_data.Accuracy]);
            mobileAverageF(end + 1) = mean([basic_data.AverageF1, complex_data.AverageF1]);
        end
    end  
end 

%% Sort the data so it looks nice
[alexSorted, alexOrder] = sort(alexLearningRates);
alexAverageTime = alexAverageTime(alexOrder);
alexAverageF = alexAverageF(alexOrder);
alexAverageAcc = alexAverageAcc(alexOrder);

[googleSorted, googleOrder] = sort(googleLearningRates);
googleAverageTime = googleAverageTime(googleOrder);
googleAverageF = googleAverageF(googleOrder);
googleAverageAcc = googleAverageAcc(googleOrder);

[mobileSorted, mobileOrder] = sort(mobileLearningRates);
mobileAverageTime = mobileAverageTime(mobileOrder);
mobileAverageF = mobileAverageF(mobileOrder);
mobileAverageAcc = mobileAverageAcc(mobileOrder);

%% Graph average times
semilogx(alexSorted, alexAverageTime, 'o','MarkerFaceColor',[0 0.447 0.741])
hold on
semilogx(alexSorted, alexAverageTime, 'Color', [0 0.447 0.741])

semilogx(googleSorted, googleAverageTime, 'o','MarkerFaceColor',[0.741 0 0])
semilogx(googleSorted, googleAverageTime, 'Color', [0.741 0 0])

semilogx(mobileSorted, mobileAverageTime, 'o','MarkerFaceColor',[0 0.741 0])
semilogx(mobileSorted, mobileAverageTime, 'Color', [0 0.741 0])

grid on
legend('AlexNet', '','GoogleNet','', 'MobileNet', '')

tit = sprintf('Average Training Time for each Neural Network');
title(tit)
xlabel('Learning Rate (log)')
ylabel('Time (seconds)')

filename = sprintf("%s/averageTime.png", PATHGraphs);
saveas(gcf, filename);
close all;

%% Graph average accuracies
semilogx(alexSorted, alexAverageAcc, 'o','MarkerFaceColor',[0 0.447 0.741])
hold on
semilogx(alexSorted, alexAverageAcc, 'Color', [0 0.447 0.741])

semilogx(googleSorted, googleAverageAcc, 'o','MarkerFaceColor',[0.741 0 0])
semilogx(googleSorted, googleAverageAcc, 'Color', [0.741 0 0])

semilogx(mobileSorted, mobileAverageAcc, 'o','MarkerFaceColor',[0 0.741 0])
semilogx(mobileSorted, mobileAverageAcc, 'Color', [0 0.741 0])

grid on
legend('AlexNet', '','GoogleNet','', 'MobileNet', '')

tit = sprintf('Average Final Validation Accuracy for each Neural Network');
title(tit)
ylabel('Final Validation Accuracy (%)')
xlabel('Learning Rate (log)')

filename = sprintf("%s/averageAcc.png", PATHGraphs);
saveas(gcf, filename);
close all;

%% Graph average accuracies
semilogx(alexSorted, alexAverageF, 'o','MarkerFaceColor',[0 0.447 0.741])
hold on
semilogx(alexSorted, alexAverageF, 'Color', [0 0.447 0.741])

semilogx(googleSorted, googleAverageF, 'o','MarkerFaceColor',[0.741 0 0])
semilogx(googleSorted, googleAverageF, 'Color', [0.741 0 0])

semilogx(mobileSorted, mobileAverageF, 'o','MarkerFaceColor',[0 0.741 0])
semilogx(mobileSorted, mobileAverageF, 'Color', [0 0.741 0])

grid on
legend('AlexNet', '','GoogleNet','', 'MobileNet', '')

tit = sprintf('Average Average F-Score for each Neural Network');
title(tit)
ylabel('Average F-Score')
xlabel('Learning Rate (log)')

filename = sprintf("%s/averageF.png", PATHGraphs);
saveas(gcf, filename);
close all;

%% Print long stuff
format bank

%% Print averages of all metrics
mobileNetAverageFscoreOverall = mean(mobileAverageF)
googleNetAverageFscoreOverall = mean(googleAverageF)
alexNetaverageFscoreOveral = mean(alexAverageF)

mobileNetAverageAccOverall = mean(mobileAverageAcc)
googleNetAverageAccOverall = mean(googleAverageAcc)
alexNetAverageAccOverall = mean(alexAverageAcc)

mobileNetAverageTime = mean(mobileAverageTime);
mobilehms = fix(mod(mobileNetAverageTime, [0, 3600, 60]) ./ [3600, 60, 1])
googleNetAverageTime = mean(googleAverageTime);
googlehms = fix(mod(googleNetAverageTime, [0, 3600, 60]) ./ [3600, 60, 1])
alexNetAverageTime = mean(alexAverageTime);
alexhms = fix(mod(alexNetAverageTime, [0, 3600, 60]) ./ [3600, 60, 1])

%% Resets format.
format long