close all
clear
clc

%% Read Database
% Add local library and data to the path
addpath(genpath('lib'));
addpath(genpath('data'));
% Read raw data
disp('Reading database from local files...')
load('data/data.mat','X','y')
% Divide dataset into training and test set
[Xtrain,Ytrain,Xtest,Ytest] = divide_train_test(X,y);
disp('Local data read!')
fprintf('\n-Comedy films: %i',sum(y==0))
fprintf('\n-Drama  films: %i\n\n',sum(y==1))

%% Feature Extraction Stage
disp('Feature Extraction Stage in progress...')
% Creating empy array of features
features = zeros(length(Xtrain),5);

%% Visual Feature Extraction
disp('Extracting visual features...')
for i = 1:length(Xtrain)
    
    % Select current image
    I = Xtrain{i} ;
    
    %%% Feature 1: Dominant Colours
    % Convert I to HSV image
    HSV = rgb2hsv(I) ;
    % Select Hue component
    H = HSV(:,:,1) ;
    % Obtain the variability in colour (entropy)
    colour_entropy = entropy(H) ;
    % Save feature
    features(i,1) = colour_entropy ;
    
    %%% Feature 2: Brightness
    % Extract the Value channel from HSV image
    V = HSV(:,:,3) ;
    % Obtain the mean value of the Value channel
    brightness = mean(V(:)) ;
    % Save feature
    features(i,2) = brightness ;
    
    %%% Feature 3: Edges
    % Convert I to gray-scale image
    Ig = rgb2gray(I) ;
    % Obtain edge image using the Sobel filter
    BW = edge(Ig,'Sobel') ;
    % Get the amount of edges in the BW image
    edge_quantity = sum(BW(:)) ;
    % Save feature
    features(i,3) = edge_quantity ;    
  
end


%% Textual Feature Extraction
disp('Extracting textual features...')

arrayText = Xtrain(:,2) ;

for i = 1:length(Xtrain)

    % Select current text
    T = arrayText(i) ;
 
    % Tokenize document (separate into words)
    words = obtain_word_array(T);
    
    %%% Feature 4: Number of words
    % Obtain the number of words (tokens)
    num_words = length(words) ;
    % Save feature
    features(i,4) = num_words ;  
    
    %%% Feature 5: Length of words
    % Obtain the length of each word in the description
    word_lengths = 0 ;
    for j = 1:length(words)
        word_lengths = word_lengths + strlength(words(j));
    end
    
    % Obtain the mean length of the words in the description
    mean_word_length = word_lengths/length(words) ;
    % Save feature
    features(i,5) = mean_word_length; 
    
    %%%%%%%%%%%%%%%%%%
    %       P9       %
    %%%%%%%%%%%%%%%%%%
%     bag = bagOfWords(lower(words));
%     topkwords(bag, 10)

end
disp('Feature Extraction complete!')

%% Normalization Stage
disp('Normalization Stage in progress...')
% Obtain the mean of each feature
feat_mean = mean(features) ;
% Obtain the standard deviation of each feature
feat_std  = std(features) ;
% Normalize the extracted features
size = size(features);
features_n = zeros(960,5);

for i = 1:size(2)
    for j = 1:size(1)
        features_n(j,i) = (features(j,i) - feat_mean(i)) / feat_std(i);
    end
end


% Check if normalization was correctly implemented (VERY IMPORTANT)
% If normalization was correctly implemented, running the line below should
% print the message saying so.
check_normalization(features_n);

%% Feature Visualization
% Select pair of features to visualize:
%   -1: Colour
%   -2: Brightness
%   -3: Edges
%   -4: Word number
%   -5: Word length
feat_a = 1 ;
feat_b = 2 ;
% Plot feature values in scatter diagram
% figure()
% visualize_features(features_n, Ytrain, feat_a, feat_b)

%% Training Stage
disp('Training Stage in progress...')
% Train model with all features available
model = fit_gaussian(features_n,Ytrain);
% Train model with just visual  features
visual_model = fit_gaussian(features_n(:,[1 2 3]),Ytrain);
% Train model with just textual features
textual_model = fit_gaussian(features_n(:,[4 5]),Ytrain);
disp('Training completed!')

%% Test Stage
disp('Testing Stage in progress...')
% IMPORTANT!!!
% Test images need to undergo the exact same process as training images
% Note that you can extract both types of features within the same loop
features_test = zeros(length(Xtest),5);

%% Test sample processing
for i = 1:length(Xtest)
    
    % Select current image
    I = Xtest{i} ;
    
    %%% Feature 1: Dominant Colours
    % Convert I to HSV image
    HSV = rgb2hsv(I) ;
    % Select Hue component
    H = HSV(:,:,1) ;
    % Obtain the variability in colour (entropy)
    colour_entropy = entropy(H) ;
    % Save feature
    features_test(i,1) = colour_entropy ;
    
    %%% Feature 2: Brightness
    % Extract the Value channel from HSV image
    V = HSV(:,:,3) ;
    % Obtain the mean value of the Value channel
    brightness = mean(V(:)) ;   
    % Save feature
    features_test(i,2) = brightness ;
    
    %%% Feature 3: Edges
    % Convert I to gray-scale image
    Ig = rgb2gray(I) ;
    % Obtain edge image using the Sobel filter
    BW = edge(Ig,'Sobel') ;
    % Get the amount of edges in the BW image
    edge_quantity = sum(BW(:)) ;
    % Save feature
    features_test(i,3) = edge_quantity ;   
    
end

arrayText = Xtest(:,2) ;

for i = 1:length(Xtest)

    % Select current text
    T = arrayText(i) ;
    
    % Tokenize document (separate into words)
    words = obtain_word_array(T);
    
    %%% Feature 4: Number of words
    % Obtain the number of words (tokens)
    num_words = length(words) ;
    % Save feature
    features_test(i,4) = num_words ;  
    
    %%% Feature 5: Length of words
    % Obtain the length of each word in the description
    word_lengths = 0 ;
    for j = 1:length(words)
        word_lengths = word_lengths + strlength(words(j));
    end
    
    % Obtain the mean length of the words in the description
    mean_word_length = word_lengths/length(words) ;
    % Save feature
    features_test(i,5) = mean_word_length; 

end



%% Test sample normalization
%%% Perform Normalization
% Note that you do not need to recompute the mean and standard deviation
% again. You need to use the values from training

clear size

size = size(features_test);
features_test_n = zeros(640,5);

for i = 1:size(2)
    for j = 1:size(1)
        features_test_n(j,i) = (features_test(j,i) - feat_mean(i)) / feat_std(i);
    end
end

%% Test the models against the new extracted features
% Test visual  model
[labels_pred_v, scores_pred_v] = predict_gaussian(visual_model, ...
                                                  features_test_n(:,[1 2 3]));
% Test textual model
[labels_pred_t, scores_pred_t] = predict_gaussian(textual_model, ...
                                                  features_test_n(:,[4 5]));
% Test global  model
[labels_pred, scores_pred]     = predict_gaussian(model, ...
                                                  features_test_n);

%% Performance Assessment Stage
disp('Performance Assessment Stage in progress...')
labels_true = Ytest;
% Measure the performance of the developed system (Detection & False Alarm)
posit_correct = 0;
posit_sample = 0;
false_posit = 0;
false_sample = 0;

for i = 1:length(labels_pred)
    if (labels_pred(i) == labels_true(i))
        posit_correct = posit_correct + 1;
    end
    if (labels_pred(i) == 1)
        posit_sample = posit_sample + 1;
    end
    if (labels_pred(i) == -1 && labels_true(i) == 1)
        false_posit = false_posit + 1;
    end
    if (labels_pred(i) == -1)
        false_sample = false_sample + 1;
    end
end

P_D  = posit_correct / posit_sample;
P_FA = false_posit / false_sample;
fprintf('Probabilidad de deteccion (P_D) = %f\n', P_D)
fprintf('Probabilidad de falsa alarma (P_FA) = %f\n', P_FA)

% Measure the performance of the developed system (AUC)
% (NO NEED TO CODE ANYTHING HERE)
[X1,Y1,T1,AUC1] = perfcurve(Ytest',scores_pred_v,1);
[X2,Y2,T2,AUC2] = perfcurve(Ytest',scores_pred_t,1);
[X3,Y3,T3,AUC3] = perfcurve(Ytest',scores_pred,1);
figure(2),area(X3,Y3,'FaceColor','Green','FaceAlpha',0.5)
hold on
figure(2),area(X3,X3,'FaceColor','White','FaceAlpha',0.7)
figure(2), plot(X3,Y3,'k','LineWidth',5)
figure(2), plot(X3,X3,'k--','LineWidth',5)
figure(2),area(X1,Y1,'FaceColor','Blue','FaceAlpha',0.5)
figure(2),area(X1,X1,'FaceColor','White','FaceAlpha',0.7)
figure(2), plot(X1,Y1,'k','LineWidth',5)
figure(2), plot(X1,X1,'k--','LineWidth',5)
figure(2),area(X2,Y2,'FaceColor','Red','FaceAlpha',0.5)
figure(2),area(X2,X2,'FaceColor','White','FaceAlpha',0.7)
figure(2), plot(X2,Y2,'k','LineWidth',5)
figure(2), plot(X2,X2,'k--','LineWidth',5)
title(['AUC (I) = ' num2str(AUC1) ' - AUC (T) = ' num2str(AUC2) ' - AUC (I+T) = ' num2str(AUC3)])
disp('Performance Assessed!')

save('data/features.mat','features','features_test','features_n','features_test_n');
