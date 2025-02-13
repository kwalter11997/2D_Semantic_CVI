%% oculomotor 2D image
addpath(genpath('E:\2D_Semantic_CVI')) %work desktop
% addpath(genpath('C:\KerriWork\SemanticCVI')) %home desktop
clearvars -except avgFix_control

height = 1200;
width = 1600; %size of images
cd('E:\2D_Semantic_CVI') %work desktop
% cd('C:\KerriWork\SemanticCVI') %home desktop

%work desktop
% fnames = dir('E:\2D_Semantic_CVI\Semantic_Raw_Data\control');
% cd('E:\2D_Semantic_CVI\Semantic_Raw_Data\control')
fnames = dir('E:\2D_Semantic_CVI\Semantic_Raw_Data\CVI')
cd('E:\2D_Semantic_CVI\Semantic_Raw_Data\CVI')

%home desktop
% fnames = dir('C:\KerriWork\SemanticCVI\Semantic_Raw_Data\control')
% cd('C:\KerriWork\SemanticCVI\Semantic_Raw_Data\control')
% fnames = dir('C:\KerriWork\SemanticCVI\Semantic_Raw_Data\CVI')
% cd('C:\KerriWork\SemanticCVI\Semantic_Raw_Data\CVI')

fnames = {fnames.name};
fnames = fnames(3:end); %remove . and ..

for s = 1:length(fnames)
%     count = 0;
    trialData = {};
    
    DATA = readcell(string(fnames(s)));
    %convert cells to more workable format
    tri = cell2mat(DATA(2:end,1)); %trials
%     targ = string(DATA(2:end,7)); %current target - when this isn't N/A it means scene was present
    cali = string(DATA(2:end,9)); %calibration marker
    time = cell2mat(DATA(2:end,3)); %trial time
    eyeX = cell2mat(DATA(2:end,4)); %Xpos
    eyeY = cell2mat(DATA(2:end,5)); %Ypos
    vis = string(DATA(2:end,10)); %target visable
    
    for n=1:max(tri)       
%         if all(strcmp('N/A',targ(tri==n,:))) %if this was a calibration trial
        if any(strcmp('Calibration',cali(tri==n,:))) %if this was a calibration trial
            continue
        else
            idx = find(strcmp('TargetVisible',vis(tri==n))); %index of where scene appears
            temp = [time(tri==n),eyeX(tri==n),eyeY(tri==n)]; %temporary matrix
            trialData{1,n} = temp(idx:end,:); %final matrix (values only after stimulus presentation)
        end
    end

    trialData = trialData(~cellfun('isempty',trialData)); %remove empty (calibration) cells

    for t=1:length(trialData)
        %convert times to frames
        data = trialData{1,t};

        data(:,1) = data(:,1)*60; %tobii rate is 60 frames per second
%         data(:,1) = [1:length(data)]';

        offscreen = data(:,2)<0 | data(:,3)<0 | data(:,2)>1 | data(:,3)>1; %remove values outside 0 and 1 (offscreen) values
        data(offscreen,2:3) = NaN;

        %reorganize gaze data in terms of pixels
        x = data(:,2);
        y = data(:,3);

        data(:,2) = round(width*x); %scale according to image pixels
        data(:,3) = round(height*(1-y));

        trialData{1,t} = data;
    end

%     warning('') % Clear last warning message  
    
    %label fixations with Mould's function
    [PoG_samples_withfixlabels, opt_duration_thresh, opt_speed_thresh] = NonParaFixLab(trialData);

%     [warnmsg, msgid] = lastwarn;
%     testingData = trialData; %create temporary testing variable
%     if strcmp(msgid,'MATLAB:nearlySingularMatrix') %if warning was thrown
%        for w = 1:40 %run trials one by one
%            warning('') % Clear last warning message   
%            [PoG_samples_withfixlabels, opt_duration_thresh, opt_speed_thresh] = NonParaFixLab(testingData(w)); 
%            [warnmsg, msgid] = lastwarn;
%            if strcmp(msgid,'MATLAB:nearlySingularMatrix') %if warning was thrown
%               trialData(w) = []; %remove problem trials
%               count = count+1; %keep track of how many trials we're removing
%            end
%        end
%       [PoG_samples_withfixlabels, opt_duration_thresh, opt_speed_thresh] = NonParaFixLab(trialData); %rerun without problem trials 
%     end     
%     removedTrials(s) = count; %count removed trials as a subject matrix
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fixNum = zeros(1,length(PoG_samples_withfixlabels)); %preallocate fixNum vector
    for f=1:length(PoG_samples_withfixlabels) 
        sample = PoG_samples_withfixlabels{f}; %go through samples one by one

        fixNum(f) = length(find(sample(:,5)==1 & circshift(sample(:,5),1)==0)); %find the first 1s in a sequence
        if sample(1,5)==1 & sample(end,5)==1 %if trial started and ended with fixations the above line will mash them together as 1, add a fixation to counteract this
            fixNum(f) = fixNum(f)+1;
        end
    end

%     [warnmsg, msgid] = lastwarn;
%     if strcmp(msgid,'MATLAB:nearlySingularMatrix') %if warning was thrown
%         fixNum = NaN; %don't count this subj
%     end
        
%     C = {'r','g','m','y','c','k','b'}; %color vector for plotting

    % parse through plot
%     for t=1:length(PoG_samples_withfixlabels)
%         clear fixStart;clear fixEnd;
%         sample = PoG_samples_withfixlabels{t}; %go through samples one by one
%         nfix=[];
%         c=1; %counter
% 
%         figure; hold on
%         %picname = sprintf('E:\\2D_Image_CVI\\Images_jpg\\Slide%d.jpg',t);%work desktop
% %         picname = sprintf('C:\\KerriWork\\2D_Image\\Images_jpg\\Slide%d.jpg', t);%home desktop
% %         pic = imread(picname);
% %         imagesc(pic); set(gca, 'YDir','reverse')
%         scatter(sample(:,2),sample(:,3),'bx');
%         plot(sample(:,2),sample(:,3))
%         xlim([0,width])
%         ylim([0,height])
%         xlabel('Xpos')
%         ylabel('Ypos')
%         title('Semantic Gaze Plot')
    
    trialFix(s,:) = fixNum; %total fix matrix
    
    if contains(fnames(s),'Img')
        avgFixImg(s) = mean(fixNum);
    elseif contains(fnames(s),'Txt');
        avgFixTxt(s) = mean(fixNum);
    end
end

avgFixImg(avgFixImg==0)=[];
avgFixTxt(avgFixTxt==0)=[];

avgFixTxt = [avgFixTxt(1:2) NaN avgFixTxt(3:end)]  %CVI subj3 doesn't have a Txt file

% avgFix_control = [avgFixImg;avgFixTxt]
avgFix_cvi = [avgFixImg;avgFixTxt]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('avgFix')
load('fixType')

mean(avgFix_control)
mean(avgFix_cvi)

data = [avgFix_control avgFix_cvi];
G = [zeros(size(avgFix_control)),ones(size(avgFix_cvi))];
boxplot(data,G,'Labels',{'Control','CVI'})
hold on
scatter(ones(size(avgFix_control)),avgFix_control,'or')
scatter(ones(size(avgFix_cvi))+1,avgFix_cvi,'or')
ylabel('Average Fixations')
title('Average # of Fixations')

[h,p,ci,stats] = ttest2(avgFix_control,avgFix_cvi)


%% Counts plot

avgFix_control
avgFix_cvi

h=histogram(avgFix_control(:),'NumBins',10,'BinWidth',1,'FaceColor','r','FaceAlpha',.5)
hold on;
histogram(avgFix_cvi(:),'NumBins',10,'BinWidth',1,'FaceColor','b','FaceAlpha',.5)
ylabel('Count')
xlabel('Number of Fixations')
legend('Control', 'CVI')
