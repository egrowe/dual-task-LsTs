function runExp1_centralSOA_LsTs
%% DUAL ATTENTIONAL (VISUAL DISCRIMINATION) TASK %%
% Central Task = Display of letters in circle (4 Conditions: All L's, All T's, 4 L's
% and 1 T or 4 T's and 1 L) before a mask (T = Central SOA, cSOA) of all F's
% Perihperal Task = Presentation of a face (either male or female) at one
% point in the periphery before a random mask of a scrambled face (T = Peripheral SOA, pSOA) is presented.

% noCST: Number of blocks in central single task condition
% noPST: Number of blocks in peripheral single task condition
% noDT: Number of blocks in dual task condition
% RANDOMIZE: Boolean, randomize blocks YES/NO
%
% NB. This experiment is designed for 60Hz presentation!

dbstop if error

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% DEFINE BLOCKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blocks = [1,1];
nBlocks = length(blocks);

UseQUEST = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% LOAD EXPERIMENTAL PARAMETERS %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp_Parameters1_LsTs;

tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% LOAD PREVIOUS QUESTs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

path = ['../data/raw/Exp1/' Gral.subjNo '_' Gral.subjID '/' Gral.subjNo '_' Gral.subjID '_']; %#ok<*NODEF>
prevSession = num2str(str2num(Gral.session)-1); %#ok<*ST2NM>
prevRun = num2str(str2num(Gral.run)-1);

if str2num(Gral.session) > 1 && str2num(Gral.run) == 1
    clear q p;
    if exist([path prevSession '_4.mat'],'file')
        load([path prevSession '_4.mat'], 'q', 'p');
    else
        load([path prevSession '_3.mat'], 'q', 'p');
    end
elseif str2num(Gral.session) > 1 && str2num(Gral.run) > 1
    clear q p;
    load([path Gral.session '_' prevRun '.mat'], 'q', 'p');
elseif str2num(Gral.session) == 1 && str2num(Gral.run) > 1
    clear p q;
    load([path Gral.session '_' prevRun '.mat'], 'q', 'p');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RUN BLOCKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for b = 1:nBlocks
    
    % Determine condition
    cond = blocks(b);
    
    % Create new QUEST if central task
    if cond == 1
        cSOA_estim = QuestMean(q);
        SDcSOA_guess = 3;
        beta = q.beta;
        delta = q.delta;
        gamma = q.gamma;
        q=QuestCreate(cSOA_estim,SDcSOA_guess,pThreshold,beta,delta,gamma,1,50);
        q.normalizePdf=1;
    end
    
    % Show instructions
    show_instructions(cond, Cfg);
    
    % Remove old data
    
    empty = cell(1,nTrials);
    [TR(:).c_keyid] = empty{:};
    [TR(:).c_confidence] = empty{:};
    [TR(:).mouseResponsesMain] = empty{:};
    [TR(:).c_response] = empty{:};
    
    [TR(:).p_keyid] = empty{:};
    [TR(:).p_confidence] = empty{:};
    [TR(:).mouseResponsesPer] = empty{:};
    [TR(:).p_response] = empty{:};
    
    randi = randperm(nTrials);
    
    for tr = 1:nTrials
        
        % retrieve QUEST estimates
        TR(tr).cSOA = round(QuestMean(q));
        TR(tr).true_cSOA = QuestMean(q);
        TR(tr).pSOA = round(QuestMean(p));
        TR(tr).true_pSOA = QuestMean(p);
        
        % Run Trials
        TR = show_trial(TR, Cfg, tr, cond);
        
        % Update Quests
        if UseQUEST
            if cond == 1
                q=QuestUpdate(q,TR(tr).cSOA,TR(tr).c_response);
            end
        end
    end
    
    
    % Store current block and condition in data
    Data(b).TR = TR; %#ok<*AGROW>
    Data(b).condition = cond;
    Data(b).estim_cSOA = [];
    Data(b).estim_pSOA = [];
    Data(b).c_performance = [];
    Data(b).p_performance = [];
    
    % Store performance and SOAs
    switch cond
        case 1
            Data(b).c_performance = sum([TR(:).c_response])/nTrials;
            Data(b).estim_cSOA = QuestMean(q);
        case 2
            Data(b).p_performance = sum([TR(:).p_response])/nTrials;
            Data(b).estim_pSOA = QuestMean(p);
        case 3
            Data(b).c_performance = sum([TR(:).c_response])/nTrials;
            Data(b).p_performance = sum([TR(:).p_response])/nTrials;
            Data(b).estim_cSOA = QuestMean(q);
            Data(b).estim_pSOA = QuestMean(p);
    end
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% DISPLAY THE SOA after the central single-task (re-run this block if SOA > 350 ms)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        SOA_in_ms = (Data(b).estim_cSOA)*(1000/60)
        
        disp(['This participants central SOA was ' num2str(SOA_in_ms) ' ms'])
        
        if Data(b).estim_cSOA < 21
            disp('Yay! Performance level reached! End of this block')
            break
        elseif Data(b).estim_cSOA >= 21
            disp('Uh oh! Performance level WAS NOT reached! This block will repeat')
        end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SAVE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Gral.exptotalDuration = toc;

fileName_trial = [path Gral.session '_' Gral.run, '.mat'];
save(fileName_trial, 'Data', 'p', 'q', 'Cfg', 'Gral');

% Last flip to show the final painted square on the screen
Screen('FillRect', Cfg.windowPtr, 0);
for m = 1 : TR(tr).screenInterval % In Frames! (eg 60hz = 15 = 250ms)
    Screen('Flip', Cfg.windowPtr, [], Cfg.aux_buffer);
end

Screen('TextSize',Cfg.windowPtr,20);
Screen('DrawText', Cfg.windowPtr, 'End of Session.', Cfg.xCentre-80, Cfg.yCentre, [255 255 255]);
for m = 1 : TR(tr).screenInterval % In Frames! (eg 60hz = 15 = 250ms)
    Screen('Flip', Cfg.windowPtr, [], Cfg.aux_buffer);
end
WaitSecs(3);


%% close all windows / devices opened
ShowCursor;
sca

end

%% Function definitions


function TR = show_trial(TR, Cfg, tr, cond)


HideCursor;



%% Draw Fixation Cross on Centre of Screen
%Draw the lines
Screen('DrawLines', Cfg.windowPtr, Cfg.crossLines, Cfg.crossWidth, Cfg.crossColour, [Cfg.xCentre, Cfg.yCentre]);

% Duration of fixation cross presentation: 300 +/- 100 ms
jitter = randi([0 2],1);
TR(tr).crosstrialDur = TR(tr).crosstrialDur + jitter * 6;

for m = 1 : (TR(tr).crosstrialDur) % In Frames! (eg 60hz = 15 = 250ms)
    Screen('Flip', Cfg.windowPtr, [], Cfg.aux_buffer);
end


Screen('FillRect', Cfg.windowPtr, 0);
for m = 1 : TR(tr).intertrialInt % In Frames! (eg 60hz = 15 = 250ms)
    Screen('Flip', Cfg.windowPtr, [], Cfg.aux_buffer);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% PRESENT STUMULI DEPENDING ON cSOA and pSOA %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine number of frames to be presented
if TR(tr).pSOA >= TR(tr).cSOA
    nFrames = TR(tr).pSOA + 3;
else
    nFrames = TR(tr).cSOA + 2;
end

% Convert these parameters for presentation from flips/nFrames into ms
convert = (1000/60)/1000; %convert to ms from frames and then seconds

l_start = 1*convert;
l_dur = TR(tr).cSOA*convert;

f_start = 2*convert;
f_dur = TR(tr).pSOA*convert;

lmask_start = (TR(tr).cSOA + 1)*convert;
lmask_dur = (nFrames - TR(tr).cSOA)*convert;

fmask_start = (TR(tr).pSOA + 2)*convert;
fmask_dur = (nFrames - (TR(tr).pSOA + 1))*convert;

trialDur = nFrames*convert;
eachTrialDur(tr) = trialDur;

% GET START TIME OF EXP ACCORDING TO THE SCREEN FLIP (more accurate than
% looping through nFrames!)
Screen('FillRect', Cfg.windowPtr, 0);
StartTime = Screen('Flip',Cfg.windowPtr); %record the clock time at the beginning
exp_Time_Ms = 0; %run the loops for this many frames (timing is incorrect and 1 flip/nFrame does not equal the refresh rate of the monitor

while exp_Time_Ms <= trialDur
    
    exp_Time_Ms = (GetSecs - StartTime)
    
    % Clear screen
    Screen('FillRect', Cfg.windowPtr, 0);
    
    if exp_Time_Ms >= l_start && exp_Time_Ms < (l_start + l_dur)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%% Draw Ts and Ls (DEP ON targetTrialType SPECIFIED ABOVE) %%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        Screen('DrawTextures', Cfg.windowPtr, TR(tr).xTexture, [], [TR(tr).centreLetterRect; TR(tr).rectsMain]', TR(tr).ang(1:5));
        
        %Sets the rewriting of one of the letters (either T or L) to the opposite)
        switch(TR(tr).targetTrialType)
            case{0,1}
               Screen('DrawTextures', Cfg.windowPtr, TR(tr).xTexture, [], [TR(tr).centreLetterRect; TR(tr).rectsMain]', TR(tr).ang(1:5));
            case 2
                Screen('DrawTexture', Cfg.windowPtr, TR(tr).T_texture, [], TR(tr).rectsMain(TR(tr).reWriteLetterPos,:), TR(tr).ang(TR(tr).reWriteLetterPos+1));
            case 3
                Screen('DrawTexture', Cfg.windowPtr, TR(tr).L_texture, [], TR(tr).rectsMain(TR(tr).reWriteLetterPos,:), TR(tr).ang(TR(tr).reWriteLetterPos+1));
            otherwise
                error('Incorrect drawing central letter task Ls or Ts')
        end
        
    end
    
    if exp_Time_Ms >= f_start && exp_Time_Ms < (f_start + f_dur)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% INSERT PERIPHERAL LETTER PRESENTATION%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %Set up image for peripheral Task (letter displayed in periphery)
        fileNameLeft = ['expStim/' num2str(TR(tr).picNoLeft), '_periph.png'];
        dataStructLeft = imread(fileNameLeft);
        periphDataLeft = Screen('MakeTexture', Cfg.windowPtr, dataStructLeft);
        
        fileNameRight = ['expStim/' num2str(TR(tr).picNoRight), '_periph.png'];
        dataStructRight = imread(fileNameRight);
        periphDataRight = Screen('MakeTexture', Cfg.windowPtr, dataStructRight);
        
        % Show face
        Screen('DrawTexture', Cfg.windowPtr, periphDataLeft, [], [TR(tr).rectCirclePeriphLeft], TR(tr).angPeriphLeft(1));
        Screen('DrawTexture', Cfg.windowPtr, periphDataRight, [], [TR(tr).rectCirclePeriphRight], TR(tr).angPeriphRight(1));
        
    end
    
    if exp_Time_Ms >= fmask_start && exp_Time_Ms < (fmask_start + fmask_dur)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%% PERIPHERAL LETTER MASK PRESENTATION (F's) %%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Peripheral Mask (scrambled face displayed in periphery)
        % Set up mask for peripheral Task
        fileName = ['expStim/' num2str(TR(tr).picNo2_mask), '_periph.png'];
        dataStruct = imread(fileName);
        letterMaskData = Screen('MakeTexture', Cfg.windowPtr, dataStruct);
        
        Screen('DrawTexture', Cfg.windowPtr, letterMaskData, [], [TR(tr).rectCirclePeriphLeft], TR(tr).angPeriphMaskLeft(1));%,angles(r_indxs(1)));
        Screen('DrawTexture', Cfg.windowPtr, letterMaskData, [], [TR(tr).rectCirclePeriphRight], TR(tr).angPeriphMaskRight(1));%,angles(r_indxs(1)));
        
    end
    
    if exp_Time_Ms >= lmask_start && exp_Time_Ms < (lmask_start + lmask_dur)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%% DRAW LETTER MASKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %Set mask text images at same angles
        Screen('DrawTextures', Cfg.windowPtr, TR(tr).F_texture, [], [TR(tr).centreLetterRect; TR(tr).rectsMain]', TR(tr).angCentMask(1:5));
        
    end
    
    % Present stimuli on screen
    Screen('Flip', Cfg.windowPtr);
    
end

clear StartTime

%% intermediate screen

Screen('FillRect', Cfg.windowPtr, 0);
for m = 1 : TR(tr).screenInterval % In Frames! (eg 60hz = 15 = 250ms)
    Screen('Flip', Cfg.windowPtr, [], Cfg.aux_buffer);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% COLLECT RESPONSES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ShowCursor;

if cond == 1 || cond == 3
    responseType = 1; %#ok<*NASGU> % Need this for DrawResponseScreen script
    
    DrawResponseScreen1;
    Screen('Flip', Cfg.windowPtr,  [], Cfg.aux_buffer);
    WaitSecs(.3);
    
    clicks = 0; % flags for the responses: 2afc left, 2afc right, 5 conf left, 5 conf right
    
    % Wait until subject has given a response
    while clicks == 0
        
        [x, y] = getMouseResponse(Cfg);
        
        % Check whether the click went inside a box area
        for m = 1 : size(polyL, 1)
            idxs_left(m) = inpolygon(x,y,squeeze(polyL(m,1,:)),squeeze(polyL(m,2,:)));
            
            idxs_right(m) = inpolygon(x,y,squeeze(polyR(m,1,:)),squeeze(polyR(m,2,:)));
        end
        
        idx_pos_left = find(idxs_left == 1);
        idx_pos_right = find(idxs_right == 1);
        
        % Left boxes click
        if length(idx_pos_left) == 1
            keyid = 1;
            keyid2 = idx_pos_left;
            
            clicks = 1;
            
            % Paint selected box blue
            Screen('FillPoly', Cfg.windowPtr, [0 0 255], squeeze(polyL(idx_pos_left,:,:))',1);
            for wait = 1:10
                Screen('Flip', Cfg.windowPtr,  [], Cfg.aux_buffer);
            end
            
        end
        
        if length(idx_pos_right) == 1
            keyid = 2;
            keyid2 = idx_pos_right;
            
            clicks= 1;
            
            % Paint selected box blue
            Screen('FillPoly', Cfg.windowPtr, [0 0 255], squeeze(polyR(idx_pos_right,:,:))',1);
            for wait = 1:10
                Screen('Flip', Cfg.windowPtr,  [], Cfg.aux_buffer);
            end
            
        end
    end
    
    % Check response
    if keyid == 1
        response = 'same';
    elseif keyid == 2
        response = 'different';
    end
    
    if TR(tr).targetTrialType < 2
        trialType = 'same';
    else
        trialType = 'different';
    end
    
    TR(tr).c_keyid = keyid;
    TR(tr).c_response = strcmp(response, trialType);
    TR(tr).c_confidence = keyid2;
    
    TR(tr).mouseResponsesMain = [x y];
end

% Interstimulus interval
if cond == 3
    Screen('FillRect', Cfg.windowPtr, 0);
    Screen('Flip', Cfg.windowPtr, [], Cfg.aux_buffer);
end

if cond == 2 || cond == 3
    responseType = 2; %#ok<*NASGU> % Need this for DrawResponseScreen script
    
    DrawResponseScreen1;
    
    Screen('Flip', Cfg.windowPtr,  [], Cfg.aux_buffer);
    
    
    clicks = 0; % flags for the responses: 2afc left, 2afc right, 5 conf left, 5 conf right
    
    while clicks == 0
        
        [x, y] = getMouseResponse(Cfg);
        
        % Check whether the click went inside a box area
        for m = 1 : size(polyL, 1)
            idxs_left(m) = inpolygon(x,y,squeeze(polyL(m,1,:)),squeeze(polyL(m,2,:)));
            
            idxs_right(m) = inpolygon(x,y,squeeze(polyR(m,1,:)),squeeze(polyR(m,2,:)));
        end
        
        idx_pos_left = find(idxs_left == 1);
        idx_pos_right = find(idxs_right == 1);
        
        % Left boxes click
        if length(idx_pos_left) == 1 %~isempty(idx_pos_left)
            keyid = 1;
            keyid2 = idx_pos_left;
            
            clicks = 1;
            
            % Paint selected box blue
            Screen('FillPoly', Cfg.windowPtr, [0 0 255], squeeze(polyL(idx_pos_left,:,:))',1);
            for wait = 1:10
                Screen('Flip', Cfg.windowPtr,  [], Cfg.aux_buffer);
            end
            
            
        end
        
        if length(idx_pos_right) == 1
            keyid = 2;
            keyid2 = idx_pos_right;
            
            clicks= 1;
            
            % Paint selected box blue
            Screen('FillPoly', Cfg.windowPtr, [0 0 255], squeeze(polyR(idx_pos_right,:,:))',1);
            for wait = 1:10
                Screen('Flip', Cfg.windowPtr,  [], Cfg.aux_buffer);
            end
            
        end
    end
    
    TR(tr).p_keyid = keyid;
    TR(tr).p_confidence = keyid2;
    TR(tr).mouseResponsesPer = [x y];
    
    % Check response
    
    if keyid == 1
        resp = 'same';
    elseif keyid == 2
        resp = 'different';
    end
    
    if  strcmp(TR(tr).picNoLeft, TR(tr).picNoRight)
        trialTypePeriph = 'same';
    else
        trialTypePeriph = 'different';
    end
    
    TR(tr).p_response = strcmp(resp, trialTypePeriph);
    
end


HideCursor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Inter trial interval

Screen('FillRect', Cfg.windowPtr, 0);
for m = 1 : TR(tr).intertrialInt % In Frames! (eg 60hz = 120 = 2 secs)
    Screen('Flip', Cfg.windowPtr, [], Cfg.aux_buffer);
end

%% wait for click to proceed

if tr ~= TR(tr).nTrials
    
    Screen('TextSize',Cfg.windowPtr,20);
    DrawFormattedText(Cfg.windowPtr, '<<Click to proceed to the next trial>>','center', 'center');
    Screen('Flip', Cfg.windowPtr, [], []);
    
    % Wait for mouse click
    [~,~,buttons] = GetMouse;
    while any(buttons) % if already down, wait for release
        [~,~,buttons] = GetMouse;
    end
    while ~any(buttons) % wait for press
        [~,~,buttons] = GetMouse;
    end
    while any(buttons) % wait for release
        [~,~,buttons] = GetMouse;
    end
    
end

end


function show_instructions(cond, Cfg)

Screen(Cfg.windowPtr, 'TextSize', 20);

if cond == 1
    
    instr1 = 'Please focus on the centre of the screen and decide whether the letters first presented to you in the CENTRE are the SAME or DIFFERENT.';
    
    DrawFormattedText(Cfg.windowPtr, 'Central Task', 'center', 400, [255 255 255], 80, [], [], 2);
    DrawFormattedText(Cfg.windowPtr, instr1, 'center', 500, [255 255 255], 80, [], [], 2);
    DrawFormattedText(Cfg.windowPtr, '<<Click to begin with the first trial>>','center', 750);
    Screen('Flip', Cfg.windowPtr, [], []);
    WaitSecs(.3);
    % wait for click to proceed
    [~,~,buttons] = GetMouse;
    while any(buttons) % if already down, wait for release
        [~,~,buttons] = GetMouse;
    end
    while ~any(buttons) % wait for press
        [~,~,buttons] = GetMouse;
    end
    while any(buttons) % wait for release
        [~,~,buttons] = GetMouse;
    end
    
    
elseif cond == 2
    
    instr2 = 'Please focus on the centre of the screen and decide whether the letters presented to you in the PERIPHERY are SIMILAR or DIFFERENT.';
    
    DrawFormattedText(Cfg.windowPtr, 'Peripheral Task', 'center', 400, [255 255 255], 80, [], [], 2);
    DrawFormattedText(Cfg.windowPtr, instr2, 'center', 500, [255 255 255], 80, [], [], 2);
    DrawFormattedText(Cfg.windowPtr, '<<Click to begin with the first trial>>','center', 750);
    Screen('Flip', Cfg.windowPtr, [], []);
    WaitSecs(.3);
    % wait for click to proceed
    [~,~,buttons] = GetMouse;
    while any(buttons) % if already down, wait for release
        [~,~,buttons] = GetMouse;
    end
    while ~any(buttons) % wait for press
        [~,~,buttons] = GetMouse;
    end
    while any(buttons) % wait for release
        [~,~,buttons] = GetMouse;
    end
    
    
elseif cond == 3
    
    instr3 = 'Please focus on the centre of the screen and decide whether the letters first presented to you in the CENTRE are the SAME or DIFFERENT as well as whether the letters presented to you in the PERIPHERY are SIMILAR or DIFFERENT.';
    
    DrawFormattedText(Cfg.windowPtr, 'Dual Task', 'center', 400, [255 255 255], 80, [], [], 2);
    DrawFormattedText(Cfg.windowPtr, instr3, 'center', 500, [255 255 255], 80, [], [], 2);
    DrawFormattedText(Cfg.windowPtr, '<<Click to begin with the first trial>>','center', 750);
    Screen('Flip', Cfg.windowPtr, [], []);
    WaitSecs(.3);
    % wait for click to proceed
    [~,~,buttons] = GetMouse;
    while any(buttons) % if already down, wait for release
        [~,~,buttons] = GetMouse;
    end
    while ~any(buttons) % wait for press
        [~,~,buttons] = GetMouse;
    end
    while any(buttons) % wait for release
        [~,~,buttons] = GetMouse;
    end
    
    
end

end