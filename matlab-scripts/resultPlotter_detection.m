clear;
clc;
close all;

%% Get all the paths to .mat files
PATH_ROOT = '/home/nick/Projects/University/AVLM/semester1/results/detectionResults';
PATH_Gary_basic = sprintf("%s/garyBasic", PATH_ROOT);
PATH_Gary_complex = sprintf("%s/garyComplex", PATH_ROOT);
PATH_Nick_basic = sprintf("%s/nickBasic", PATH_ROOT);
PATH_Nick_complex = sprintf("%s/nickComplex", PATH_ROOT);

PATHS = {PATH_Gary_basic, PATH_Gary_complex, PATH_Nick_basic, PATH_Nick_complex};

%% Bins for data
learningRates = [];

garyBasicTime = [];
garyComplexTime = [];
nickBasicTime = [];
nickComplexTime = [];

garyBasicRMSE = [];
garyComplexRMSE = [];
nickBasicRMSE = [];
nickComplexRMSE = [];

%% Loop over all file paths and all .mat files
for i = 1:length(PATHS)
    for j = 1:5
        path = sprintf("%s/metrics_interation%d.mat", PATHS{i}, j);
        data = load(path).data_metrics;
        %% Make sure data goes to the right place
        if i == 1
            learningRates(end + 1) = data.LearningRate;
            garyBasicTime(end + 1) = data.Time;
            garyBasicRMSE(end + 1) = data.RMSE;
        end
        if i == 2
            garyComplexTime(end + 1) = data.Time;
            garyComplexRMSE(end + 1) = data.RMSE;
        end
        if i == 3
            nickBasicTime(end + 1) = data.Time;
            nickBasicRMSE(end + 1) = data.RMSE;
        end
        if i == 4
            nickComplexTime(end + 1) = data.Time;
            nickComplexRMSE(end + 1) = data.RMSE;
        end
    end
end

%% Sort all the data for prettification
[learningRates, order] = sort(learningRates);
garyBasicTime = garyBasicTime(order);
garyComplexTime = garyComplexTime(order);
nickBasicTime = nickBasicTime(order);
nickComplexTime = nickComplexTime(order);

garyBasicRMSE = garyBasicRMSE(order);
garyComplexRMSE = garyComplexRMSE(order);
nickBasicRMSE = nickBasicRMSE(order);
nickComplexRMSE = nickComplexRMSE(order);

%% Plot times
semilogx(learningRates, garyBasicTime, 'o', 'MarkerFaceColor', [0 0.447 0.741]);
hold on
semilogx(learningRates, garyBasicTime, 'Color', [0 0.447 0.741]);

semilogx(learningRates, garyComplexTime, 'o', 'MarkerFaceColor',[0 0 0.741]);
semilogx(learningRates, garyComplexTime, 'Color', [0 0 0.741]);

semilogx(learningRates, nickBasicTime, 'o', 'MarkerFaceColor',[0 0.741 0]);
semilogx(learningRates, nickBasicTime, 'Color', [0 0.741 0]);

semilogx(learningRates, nickComplexTime, 'o', 'MarkerFaceColor',[0.741 0 0]);
semilogx(learningRates, nickComplexTime, 'Color',[0.741 0 0]);

grid on
legend('Provided Images (basic)', '','Provided Images (complex)','', ...
    'Augmented Images (basic)', '', 'Augmented Images (complex)', '', 'Location', 'northwest');

tit = sprintf('Time Taken to Train for Each Dataset');
title(tit)
xlabel('Learning Rate (log)')
ylabel('Time (seconds)')

x0=10;
y0=10;
width=600;
height=400;
set(gcf,'position',[x0,y0,width,height])
filename = sprintf("%s/timeElapsed.png", PATH_ROOT);
saveas(gcf, filename);
close all;

%% plot average times (not used in the end)
garyMeanTime = [];
nickMeanTime = [];
for x = 1:length(garyBasicTime)
    garyMeanTime(end + 1) = (garyBasicTime(x) + garyComplexTime(x)) / 2;
    nickMeanTime(end + 1) = (nickBasicTime(x) + nickComplexTime(x)) / 2;
end

semilogx(learningRates, garyMeanTime, 'o', 'MarkerFaceColor', [0 0.447 0.741]);
hold on
semilogx(learningRates, garyMeanTime, 'Color', [0 0.447 0.741]);

semilogx(learningRates, nickMeanTime, 'o', 'MarkerFaceColor',[0.741 0 0]);
semilogx(learningRates, nickMeanTime, 'Color', [0.741 0 0]);

grid on
legend('Provided Images', '','Augmented Images','', ...
    'Location', 'northwest');

tit = sprintf('Average Time Taken to Train Any Dataset (complex or basic)');
title(tit)
xlabel('Learning Rate (log)')
ylabel('Time (seconds) (mean)')

x0=10;
y0=10;
width=600;
height=400;
set(gcf,'position',[x0,y0,width,height])
filename = sprintf("%s/timeElapsedAverage.png", PATH_ROOT);
saveas(gcf, filename);
close all;
%% plot RMSE
semilogx(learningRates, garyBasicRMSE, 'o', 'MarkerFaceColor', [0 0.447 0.741]);
hold on
semilogx(learningRates, garyBasicRMSE, 'Color', [0 0.447 0.741]);

semilogx(learningRates, garyComplexRMSE, 'o', 'MarkerFaceColor',[0 0 0.741]);
semilogx(learningRates, garyComplexRMSE, 'Color', [0 0 0.741]);

semilogx(learningRates, nickBasicRMSE, 'o', 'MarkerFaceColor',[0 0.741 0]);
semilogx(learningRates, nickBasicRMSE, 'Color', [0 0.741 0]);

semilogx(learningRates, nickComplexRMSE, 'o', 'MarkerFaceColor',[0.741 0 0]);
semilogx(learningRates, nickComplexRMSE, 'Color',[0.741 0 0]);

grid on
legend('Provided Images (basic)', '','Provided Images (complex)','', ...
    'Augmented Images (basic)', '', 'Augmented Images (complex)', '', 'Location', 'northwest');

tit = sprintf('Final Validation RMSE for Each Dataset');
title(tit)
xlabel('Learning Rate (log)')
ylabel('RMSE')

x0=10;
y0=10;
width=600;
height=400;
set(gcf,'position',[x0,y0,width,height])
filename = sprintf("%s/RMSE.png", PATH_ROOT);
saveas(gcf, filename);
close all;

%% plot RMSE Exlucding anom
semilogx(learningRates(1:4), garyBasicRMSE(1:4), 'o', 'MarkerFaceColor', [0 0.447 0.741]);
hold on
semilogx(learningRates(1:4), garyBasicRMSE(1:4), 'Color', [0 0.447 0.741]);

semilogx(learningRates(1:4), garyComplexRMSE(1:4), 'o', 'MarkerFaceColor',[0 0 0.741]);
semilogx(learningRates(1:4), garyComplexRMSE(1:4), 'Color', [0 0 0.741]);

semilogx(learningRates(1:4), nickBasicRMSE(1:4), 'o', 'MarkerFaceColor',[0 0.741 0]);
semilogx(learningRates(1:4), nickBasicRMSE(1:4), 'Color', [0 0.741 0]);

semilogx(learningRates(1:4), nickComplexRMSE(1:4), 'o', 'MarkerFaceColor',[0.741 0 0]);
semilogx(learningRates(1:4), nickComplexRMSE(1:4), 'Color',[0.741 0 0]);

grid on
legend('Provided Images (basic)', '','Provided Images (complex)','', ...
    'Augmented Images (basic)', '', 'Augmented Images (complex)', '', 'Location', 'northwest');

tit = sprintf('Final Validation RMSE for Each Dataset (Excluding 0.1 Learning Rate)');
title(tit)
xlabel('Learning Rate (log)')
ylabel('RMSE')

x0=10;
y0=10;
width=600;
height=400;
set(gcf,'position',[x0,y0,width,height])
filename = sprintf("%s/RMSEto4.png", PATH_ROOT);
saveas(gcf, filename);
close all;

%% plot average RMSE (not used in the end)
garyMeanRMSE = [];
nickMeanRMSE = [];
for x = 1:length(garyBasicTime)
    garyMeanRMSE(end + 1) = (garyBasicRMSE(x) + garyComplexRMSE(x)) / 2;
    nickMeanRMSE(end + 1) = (nickBasicRMSE(x) + nickComplexRMSE(x)) / 2;
end
semilogx(learningRates, garyMeanRMSE, 'o', 'MarkerFaceColor', [0 0.447 0.741]);
hold on
semilogx(learningRates, garyMeanRMSE, 'Color', [0 0.447 0.741]);

semilogx(learningRates, nickMeanRMSE, 'o', 'MarkerFaceColor',[0.741 0 0]);
semilogx(learningRates, nickMeanRMSE, 'Color', [0.741 0 0]);


grid on
legend('Provided Images', '','Augmented Images','', 'Location', 'northwest');

tit = sprintf('Average Final Validation RMSE For Any Dataset (complex or basic)');
title(tit)
xlabel('Learning Rate (log)')
ylabel('RMSE (mean)')

x0=10;
y0=10;
width=600;
height=400;
set(gcf,'position',[x0,y0,width,height])
filename = sprintf("%s/AverageRMSE.png", PATH_ROOT);
saveas(gcf, filename);
close all;

%% Ignore big results again
semilogx(learningRates(1:4), garyMeanRMSE(1:4), 'o', 'MarkerFaceColor', [0 0.447 0.741]);
hold on
semilogx(learningRates(1:4), garyMeanRMSE(1:4), 'Color', [0 0.447 0.741]);

semilogx(learningRates(1:4), nickMeanRMSE(1:4), 'o', 'MarkerFaceColor',[0.741 0 0]);
semilogx(learningRates(1:4), nickMeanRMSE(1:4), 'Color', [0.741 0 0]);


grid on
legend('Provided Images', '','Augmented Images','', 'Location', 'northwest');

tit = sprintf('Average Final Validation RMSE For Any Dataset (excluding 0.1 learning rate)');
title(tit)
xlabel('Learning Rate (log)')
ylabel('RMSE (mean)')

x0=10;
y0=10;
width=700;
height=400;
set(gcf,'position',[x0,y0,width,height])
filename = sprintf("%s/AverageRMSEto4.png", PATH_ROOT);
saveas(gcf, filename);
close all;
%% Matlab is a terrible programming language.