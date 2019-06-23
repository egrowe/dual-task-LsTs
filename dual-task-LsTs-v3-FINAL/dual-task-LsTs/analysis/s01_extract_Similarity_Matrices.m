%% Extract data from auditory similarity ratings and place into results matrix

% This script takes the appropriate datafiles once the entire experiment
% has been ran. It collects the similarity values from every stimulus pair
% and places this in a nStim x nStim matrix which can be viewed as a colour
% image. 

% There are 4 variables that will need to be changed according to your
% individual experimental design
% a) The participant name -- PName variable -- so the files save correctly at the
%    end of the script
% b) The filenames of interest -- filenames variable -- please list each of
%    the sessions of interest where the runExp script was executed, do not
%    include the MvNM sessions in this as we are not interested in these values
% c) periphOnly variable -- will be the number of the condition according to your individual
%    design that corresponds to the task where participants only responded to the
%    peripheral stimuli (e.g. disks this will be 3 or 2 matched with the next variable below, and 
%    Ls/Ts this will always be 2)
% d) periphDual variable -- will be the number of the condition corresponding to 
%    where participants responded to BOTH the peripheral and central task
%    (e.g. disks this will be 5 or 4 depending on the periphOnly (3 with 5 for the
%    full range of disk stimuli or 2 with 4 for the vertical only disk stimuli,
%    for the Ls/Ts this will always be 3)

% This code will automatically show the results for the PERIPHERAL ONLY
% (attend peripheral stimuli) and the PERIPHERAL DUAL (attend both the
% peripheral and central stimuli) as a colour image and will save these
% variables as a mat file with the name of the participant entered in PName

% The saved variables can be used to apply Multi-Dimensional Scaling (MDS) later

%ENSURE YOUR CURRENT FOLDER IS THE FOLDER CONTAINING THE PARTICIPANT DATA YOU WOULD
%LIKE TO VIEW BEFORE RUNNING THE SCRIPT :)

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

PName = ['07_WN']; %this will be used to save the results after the script has run

nStim = 8; %number of different stimuli that can be compared (i.e. 8 x 8 stimulus pairings here)

resultsMatrix_PeriphAtt = zeros(nStim,nStim); %setup to record responses to stimuli with attention
resultsMatrix_DualAtt = zeros(nStim,nStim); %setup to record responses to stimuli without attention

filenames = {'07_WN_1_2.mat'}% Participant files with data of interestest, split over multiple sessions
nSession = length(filenames); %sets the number of sessions to draw data from, as specified by the filenames above

for jj = 1:nSession

useFilename = cell2mat(filenames(jj)); %select each filename in a loop
load(useFilename); %load this filename

nTrials = size((Data(3).TR),2); %find the number of trials per block
order = ([Data.condition]); %determines the different condition numbers
periphOnly = find(order == 2) %condition number where attention is ONLY on the peripheral stimuli (here this is condition 2)
periphDual = find(order == 3) %condition number where attention is DIVIDED between central and peripheral (here this is condition 3)

%% PERIPHERAL ONLY RESULTS: Similarity Ratings
for ii = 1:nTrials
    allStimPairs_PeriphAtt{ii} = Data(periphOnly).TR(ii).periphOrder; %determines which stimulus pairs were shown in this block
end

%Place results in resultsMatrix
for getPair = 1:nTrials
    currPair = allStimPairs_PeriphAtt{getPair}; %get data from this pair, in a loop
    rr = currPair(1); %row index
    cc = currPair(2); % column index
    
    currRating = Data(periphOnly).TR(getPair).p_confidence; %pulls the similarity rating determined by current pair coordinates
    
     resultsMatrix_PeriphAtt(rr,cc) = currRating; %add the current rating to the dissimilarity matrix

end


%% DUAL TASK RESULTS: Similarity Ratings
for ii = 1:nTrials
    allStimPairs_DualAtt{ii} = Data(periphDual).TR(ii).periphOrder;  %determines which stimulus pairs were shown in this block
end

%Place results in resultsMatrix
for getPair = 1:nTrials
    currPair = allStimPairs_DualAtt{getPair}; %get data from this pair, in a loop
    rr = currPair(1); cc = currPair(2); % get row index and column index
    
    currRating = Data(periphDual).TR(getPair).p_confidence; %pulls the similarity rating determined by current pair coordinates
    
     resultsMatrix_DualAtt(rr,cc) = currRating; %compile similarity rating into a matrix
     
end

end

% %PLOT THE RESULTS FROM ABOVE AND SAVE
figure(1); imagesc(resultsMatrix_PeriphAtt,[-4 4]); %show image for the results for the attend peripheral condition
set(gca, 'FontSize', 14); xlabel('Stimulus Number','FontSize',20); ylabel('Stimulus Number','FontSize',20); title(['Results Attend Peripheral' PName]); 
saveas(gcf, [PName '_resultsMatrices_AttendPeriph'], 'png')

figure(2); imagesc(resultsMatrix_DualAtt,[-4 4]); %show image for the results for the attend both condition
set(gca, 'FontSize', 14); xlabel('Stimulus Number','FontSize',20); ylabel('Stimulus Number','FontSize',20); title(['Results Attend Both' PName]); 
saveas(gcf, [PName '_resultsMatrices_AttendBoth'], 'png')

% SAVE THE RESULTS MATRICES FOR BOTH CONDITIONS
save([PName '_resultsMatrices'], 'resultsMatrix_PeriphAtt', 'resultsMatrix_DualAtt')