%% Written on a POSIX compliant system
% If you are on windows, change windowsOrUnix to '\'!
clear;
clc;
close all;

%% Variable for reading in Unix or Windows filepaths
windowsOrUnix = '/';

%% Root strings
root_path = sprintf('..%simageData%s', windowsOrUnix, windowsOrUnix);
basic_imgs = sprintf('arucoBasic%s', windowsOrUnix);
challenging_imgs = sprintf('arucoChallenging%s',windowsOrUnix);

%% Get proper paths to images
basic_path = sprintf("%s%s", root_path, basic_imgs);
challenging_path = sprintf("%s%s", root_path, challenging_imgs);


dataStoreBasic = imageDatastore(basic_path,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[227 227]),[1,1,3]));


dataStoreChallenging = imageDatastore(challenging_path,...
                    'IncludeSubfolders',true,...
                    'LabelSource','foldernames', 'ReadFcn', ...
                    @(f) repmat(imresize(imread(f),[227 227]),[1,1,3]));
