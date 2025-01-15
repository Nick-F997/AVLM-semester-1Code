function stop = stopTraining(info,threshold)
%STOPTRAINING Function to stop training when threshold is created
%   @param info - trainNetwork metrics
%   @param threshold - threshold to compare against
%   @returns boolean - threshold met or not
    TrainingAccuracy = info.TrainingAccuracy;
    stop = TrainingAccuracy > threshold;
end

