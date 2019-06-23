%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%  SET UP OF BLOCKS, TRIAL CONDITIONS AND VARIABLES %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Set up all experimental parameters for each screen and type of stimuli

nTrials = 64;   % Number of trials per block

Gral.subjNo = input('Enter subject number, 01-99:\n','s');  %enter a subject number
Gral.subjID = input('Enter subject initials:\n','s');  %enter subject initials
Gral.session = input('Session number, 1 to 3:\n','s');  %enter number of session
Gral.run = input('Run number, 1-3:\n','s');
Gral.exptotalDuration = [];
Cfg.aux_buffer = 1;
Gral.EXP = 'EXP1';

if ~exist(['../data/raw/Exp1/' Gral.subjNo '_' Gral.subjID],'dir');
    mkdir('../data/raw/Exp1/', [Gral.subjNo '_' Gral.subjID]);
end


%%%% Reset random number generator by the clock time %%%%%
t = clock;
rng(t(3) * t(4) * t(5),'twister')

%% Initialise screen
% Screen setup using Psychtoolbox is notoriously clunky in Windows,
% particularly for dual-monitors.

% This relates to the way Windows handles multiple screens (it defines a
% 'primary display' independent of traditional numbering) and numbers
% screens in the reverse order to Linux/Mac.

% The 'isunix' function should account for the reverse numbering but if
% you're using a second monitor you will need to define a 'primary display'
% using the Display app in your Windows Control Panel. See the psychtoolbox
% system reqs for more info: http://psychtoolbox.org/requirements/#windows
Cfg.screens = Screen('Screens');

if isunix
    % Cfg.screenNumber = min(Cfg.screens); % Attached monitor
    Cfg.screenNumber = min(Cfg.screens); % Main display
else
    % Cfg.screenNumber = max(Cfg.screens); % Attached monitor
    Cfg.screenNumber = max(Cfg.screens); % Main display
end
% Window size (blank is full screen)
Cfg.WinSize = [];
% Cfg.WinSize = [10 10 1600 900];

[Cfg.windowPtr, rect] = Screen('OpenWindow', Cfg.screenNumber,0,Cfg.WinSize);

Cfg.Date= datestr(now);
Cfg.ExperimentStart = GetSecs; %store time when experiment was started
Cfg.computer = Screen('Computer');
Cfg.version = Screen('Version');
[Cfg.width, Cfg.height]=Screen('WindowSize', Cfg.windowPtr);
Cfg.FrameRate = Screen('NominalFrameRate', Cfg.windowPtr);
[Cfg.MonitorFlipInterval, Cfg.GetFlipInterval.nrValidSamples, Cfg.GetFlipInterval.stddev ] = Screen('GetFlipInterval', Cfg.windowPtr );

[x, y]=Screen('DisplaySize',0);
Cfg.xDimCm=x/10;
Cfg.yDimCm=y/10;

Cfg.distanceCm = 54;    % measured for individual set up!

%DEG VISUAL ANGLE FOR SCREEN
Cfg.visualAngleDegX = atan(Cfg.xDimCm/(2*Cfg.distanceCm))/pi*180*2;
Cfg.visualAngleDegY = atan(Cfg.yDimCm/(2*Cfg.distanceCm))/pi*180*2;

%DEG VISUAL ANGLE PER PIXEL
% Cfg.visualAngleDegPerPixelX = Cfg.visualAngleDegX/Cfg.width;
% Cfg.visualAngleDegPerPixelY = Cfg.visualAngleDegY/Cfg.height;
Cfg.visualAnglePixelPerDegX = Cfg.width/Cfg.visualAngleDegX;
Cfg.visualAnglePixelPerDegY = Cfg.height/Cfg.visualAngleDegY;
Cfg.pixelsPerDegree= mean([Cfg.visualAnglePixelPerDegX Cfg.visualAnglePixelPerDegY]); % Usually the mean is reported in papers

%% Define rectangles for response collection
Cfg.frameThickness = 20;

Cfg.rs=250; %300;% 216;
Cfg.cs=250; % 300;%150;

Cfg.rect=[0 0 Cfg.cs Cfg.rs];
Cfg.smallrect=[0 0 Cfg.cs/1.5 Cfg.rs/4];
Cfg.bigrect=[0 0 2.25*Cfg.cs 2*Cfg.rs];
Cfg.cleavage=[0 0 Cfg.cs/4 2*Cfg.rs];

Cfg.yoff = 0; % in iowa

Cfg.screensize_r = rect(4);
Cfg.screensize_c = rect(3);

Cfg.rectFrame=[0 0 Cfg.width Cfg.height]+[Cfg.screensize_c/2-Cfg.width/2 Cfg.screensize_r/2-Cfg.height/2 Cfg.screensize_c/2-Cfg.width/2 Cfg.screensize_r/2-Cfg.height/2];
Cfg.rectFrame=Cfg.rectFrame + [0 Cfg.yoff 0 Cfg.yoff];
Cfg.rect_{1} = Cfg.rect + [Cfg.screensize_c/2-Cfg.cs/2 Cfg.screensize_r/2-Cfg.height/2+Cfg.frameThickness Cfg.screensize_c/2-Cfg.cs/2 Cfg.screensize_r/2-Cfg.height/2+Cfg.frameThickness]; % top quadrant
Cfg.bigrect_{1}=Cfg.bigrect + [Cfg.screensize_c/2-1.125*Cfg.cs Cfg.screensize_r/2-Cfg.rs Cfg.screensize_c/2-1.125*Cfg.cs Cfg.screensize_r/2-Cfg.rs]; % top quadrant
Cfg.smallrect_{1}=Cfg.smallrect + [Cfg.screensize_c/2-Cfg.cs/3 Cfg.screensize_r/2-Cfg.rs/8 Cfg.screensize_c/2-Cfg.cs/3 Cfg.screensize_r/2-Cfg.rs/8]; % top quadrant

Cfg.cleavage_{1}=Cfg.cleavage + [Cfg.screensize_c/2-Cfg.cs/8 Cfg.screensize_r/2-Cfg.rs Cfg.screensize_c/2-Cfg.cs/8 Cfg.screensize_r/2-Cfg.rs];

Cfg.x=Cfg.screensize_c/2;
Cfg.y=Cfg.screensize_r/2;

Cfg.color.white= [255 255 255];
Cfg.color.black= [0 0 0];
Cfg.color.inc=(Cfg.color.white+Cfg.color.black).*0.5;
Cfg.fixColor = [0 0 0];

%% SET UP PARAMETERS FOR FIXATION CROSS

%Set colour, width, length etc.
Cfg.crossColour = 255;  %255 = white
Cfg.crossLength = 10;
Cfg.crossWidth = 1;

%Set start and end points of lines
crossLines = [-Cfg.crossLength, 0; Cfg.crossLength, 0; 0, -Cfg.crossLength; 0, Cfg.crossLength];
Cfg.crossLines = crossLines';

%% CREATE TEXTURES OF LETTERS TO DISPLAY
L_data = imread('expStim/L.jpg');
L_texture = Screen('MakeTexture', Cfg.windowPtr, L_data);

T_data = imread('expStim/T.jpg');
T_texture = Screen('MakeTexture', Cfg.windowPtr, T_data);

F_data = imread('expStim/F.jpg');
F_texture = Screen('MakeTexture', Cfg.windowPtr, F_data);


%% Set up the structures containing the info on Trials (TR), Configuration
Cfg.xCentre = rect(3)/2;
Cfg.yCentre = rect(4)/2;

%%% Create trials definition

crit = nTrials/4;

% Controlled randomization
splitTrials = nTrials/4; %split trials to Ls, Ts, L T or T L
periphOrder = [ones(1,splitTrials), ones(1,splitTrials)*2, ones(1,splitTrials)*3, ones(1,splitTrials)*4]
periphOrder = Shuffle(periphOrder);

for tr = 1 : nTrials
    
    TR(tr).periphOrder = periphOrder(tr);
    
    % Define TargetTrialTypes for each trial (control for the number of trials
    % in the different conditions) and set textures
    if tr <= crit
        TR(tr).targetTrialType = 0; %#ok<*SAGROW>
        TR(tr).xTexture = L_texture;
    elseif tr >= crit+1 && tr <= 2*crit
        TR(tr).targetTrialType = 1;
        TR(tr).xTexture = T_texture;
    elseif tr >= 2*crit+1 && tr <= 3*crit
        TR(tr).targetTrialType = 2;
        TR(tr).xTexture = L_texture;
    else
        TR(tr).targetTrialType = 3;
        TR(tr).xTexture = T_texture;
    end
    
    
    % Random selection of rotation angle
    TR(tr).ang = randperm(360);
    TR(tr).angCentMask = randperm(360);
    TR(tr).angPeriphLeft = Shuffle([45, 90, 135, 180, 225, 270, 315]); %limit the possible angle (i.e. remove 0 degrees/upright) 
    TR(tr).angPeriphRight = Shuffle([45, 90, 135, 180, 225, 270, 315]); %limit the possible angle (i.e. remove 0 degrees/upright) 
    TR(tr).angPeriphMaskLeft = Shuffle(linspace(0,315,8));
    TR(tr).angPeriphMaskRight = Shuffle(linspace(0,315,8));    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%  MAIN SETUP   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %BASIC SET UP OF THE EXPERIMENT
    TR(tr).nTrials = nTrials; %total number of trials
    
    
    % Initial values for SOAs
    TR(tr).cSOA = []; % rounded! In frames! 60hz... therefore, 30 = 500ms
    TR(tr).pSOA = []; % rounded! In frames! 60hz... therefore, 30 = 500ms
    TR(tr).true_cSOA = []; % unrounded! In frames
    TR(tr).true_pSOA = []; % unrounded! In frames
    
    TR(tr).screenInterval = 30; % In frames! 60hz... therefore, 30 = 500ms
    TR(tr).letterSize = 30; % size of the central task letters (same for L, T and F's)
    TR(tr).noLetters = 4; % number of letters to place around circle (and 1 centre)
    %TR(tr).noPeriphPoints = 20; %no of points (from which one is chosen) to display peripheral face
    TR(tr).crosstrialDur = 12; % 300 ms. In frames! 60hz... therefore, 90 = 1500ms
    TR(tr).intertrialInt = 50; % In frames! 60hz... therefore, 60 = 1sec
    TR(tr).imageHeight = 35;
    imageJust = TR(tr).imageHeight/2;
    TR(tr).F_texture = F_texture;
    TR(tr).T_texture = T_texture;
    TR(tr).L_texture = L_texture;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%  CENTRAL TASK   %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Find centre of screen for central letter presentation
    centreLeft = Cfg.xCentre - imageJust;
    centreTop = Cfg.yCentre - imageJust;
    centreRight = centreLeft + TR(tr).imageHeight;
    centreBottom = centreTop + TR(tr).imageHeight;
    TR(tr).centreLetterRect = [centreLeft, centreTop, centreRight, centreBottom];
    
    %Set coordinates for circle to present images around in the main screen
    A = rand(2); %#ok<*NASGU>
    radius = 1.5 * Cfg.pixelsPerDegree;
    anglesMain = linspace(0,2*pi,TR(tr).noLetters+1);
    anglesMain = anglesMain(1:4);
    ptsMain =[cos(anglesMain);sin(anglesMain)];
    ptsMain = ptsMain*radius;
    
    newpt1=ptsMain(1,:)+(Cfg.xCentre);
    newpt2=ptsMain(2,:)+(Cfg.yCentre);
    TR(tr).ptsMain=vertcat(newpt1, newpt2);
    
    TR(tr).anglesMain = anglesMain;
    
    %Turn these point coordinates into rects for the image to be displayed in
    plus = TR(tr).ptsMain+imageJust;
    minus = TR(tr).ptsMain-imageJust;
    rectsMain = vertcat(minus, plus);
    TR(tr).rectsMain = rectsMain';
    
    
    %Set the position for the L or T to be written as the opposite letter
    %(trial conditions 2 and 3)
    R = randperm(TR(tr).noLetters); %randomly select one position index
    TR(tr).reWriteLetterPos = R(3); %pull the 3rd positioned number from this randperm and write it below
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%  PERIPHERAL TASK  %%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Define peripheral rectangle (8x10 degree of visual angle) on which
    % the faces will be displayed
    
    xptsRectPeriph = [(-5)*Cfg.pixelsPerDegree+Cfg.xCentre 5*Cfg.pixelsPerDegree+Cfg.xCentre (-5)*Cfg.pixelsPerDegree+Cfg.xCentre 5*Cfg.pixelsPerDegree+Cfg.xCentre];
    yptsRectPeriph = [(-4)*Cfg.pixelsPerDegree+Cfg.yCentre (-4)*Cfg.pixelsPerDegree+Cfg.yCentre 4*Cfg.pixelsPerDegree+Cfg.yCentre 4*Cfg.pixelsPerDegree+Cfg.yCentre];
    TR(tr).ptsRectPeriph = vertcat(xptsRectPeriph,yptsRectPeriph);

    xptsRectPeriphB = [(5)*Cfg.pixelsPerDegree+Cfg.xCentre (-5)*Cfg.pixelsPerDegree+Cfg.xCentre (5)*Cfg.pixelsPerDegree+Cfg.xCentre (-5)*Cfg.pixelsPerDegree+Cfg.xCentre];
    yptsRectPeriphB = [(4)*Cfg.pixelsPerDegree+Cfg.yCentre (4)*Cfg.pixelsPerDegree+Cfg.yCentre (-4)*Cfg.pixelsPerDegree+Cfg.yCentre (-4)*Cfg.pixelsPerDegree+Cfg.yCentre];
    TR(tr).ptsRectPeriphB = vertcat(xptsRectPeriphB,yptsRectPeriphB);
    
    %Randomly select one point, allocate this as the position for the trial
    usePointA = randi(4,1);
    usePointB = usePointA;
    
    TR(tr).dispLocPeriph = TR(tr).ptsRectPeriph(:,usePointA)
    TR(tr).dispLocPeriphB = TR(tr).ptsRectPeriphB(:,usePointB)
    
    %Set size of the face to be displayed in the periphery
    imageHeightPeriph = 2.5 * Cfg.pixelsPerDegree;
    imageJustPeriph = imageHeightPeriph/2;
    
    %Set possible points around the circle for the Letter to appear
    plusPerA = TR(tr).dispLocPeriph+imageJustPeriph;
    minusPerA = TR(tr).dispLocPeriph-imageJustPeriph;
    rectCirclePeriphA = vertcat(minusPerA, plusPerA);
    TR(tr).rectCirclePeriphLeft = rectCirclePeriphA';
    
    plusPerB = TR(tr).dispLocPeriphB+imageJustPeriph;
    minusPerB = TR(tr).dispLocPeriphB-imageJustPeriph;
    rectCirclePeriphB = vertcat(minusPerB, plusPerB);
    TR(tr).rectCirclePeriphRight = rectCirclePeriphB';
      
    TR(tr).imageHeightPeriph = imageHeightPeriph; %heigh of face in periphery
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%% PERIPHERAL LETTERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Set Ls or Ts for main peripheral task
    
    switch(periphOrder(tr))
        case 1
            TR(tr).periphLeft = 'L';
            TR(tr).periphRight = 'L';
            TR(tr).angPeriphRight = TR(tr).angPeriphLeft; %for a match, angle must be SAME as well as letter
        case 2
            TR(tr).periphLeft = 'T';
            TR(tr).periphRight = 'T';
            TR(tr).angPeriphRight = TR(tr).angPeriphLeft; %for a match, angle must be SAME as well as letter
        case 3
            TR(tr).periphLeft = 'L';
            TR(tr).periphRight = 'T';
            %Fix the angle if it is the same on both sides
            if TR(tr).angPeriphRight(1) == TR(tr).angPeriphLeft(1)
                TR(tr).angPeriphRight(1) =  TR(tr).angPeriphLeft(2) %for a no match, angle must be DIFFERENT as well as letter
            end
        case 4
            TR(tr). periphLeft = 'T';
            TR(tr). periphRight = 'L';
            %Fix the angle if it is the same on both sides            
            if TR(tr).angPeriphRight(1) == TR(tr).angPeriphLeft(1)
                TR(tr).angPeriphRight(1) =  TR(tr).angPeriphLeft(2) %for a no match, angle must be DIFFERENT as well as letter
            end
        otherwise
            error('periphTypes R and L Not Assigned!')
    end
    
    
    %Set peripheral image to draw as a texture to display
    switch(TR(tr).periphLeft)
        case 'L'
            TR(tr).picNoLeft = 'L';
        case 'T'
            TR(tr).picNoLeft = 'T';
        otherwise
            error('PicNoLeft Not Assigned!')
    end
    
    switch(TR(tr).periphRight)
        case 'L'
            TR(tr).picNoRight = 'L'
        case 'T'
            TR(tr).picNoRight = 'T'
        otherwise
            error('PicNoRight Not Assigned')
    end
    
    %Set mask to always be Fs and set up the texture pointer to display
    TR(tr).periphLetterMask = 'F'
    picMaskPeriph = 'F';
    TR(tr).picNo2_mask = picMaskPeriph;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%  OUTPUT/SAVE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    TR(tr).mouseResponsesMain = [];
    TR(tr).c_confidence = [];
    TR(tr).mouseResponsesPer = [];
    TR(tr).p_confidence = [];
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%  QUEST  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Set parameters for QUEST
    cSOAGuess=30;
    cSOAGuessSd=20;
    pThreshold=0.7;
    beta=2;delta=0.1;gamma=0.5;
    q=QuestCreate(cSOAGuess,cSOAGuessSd,pThreshold,beta,delta,gamma,1,50);
    q.normalizePdf=1;
    
    pSOAGuess=15;
    pSOAGuessSd=8;
    p=QuestCreate(pSOAGuess,pSOAGuessSd,pThreshold,beta,delta,gamma,1,20);
    p.normalizePdf=1;
    
end

%randomize trials
TR = Shuffle(TR);