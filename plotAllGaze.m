%% Semantic Average Heatmaps
%average heatmaps for all CVI vs all Control subjects for each scene
%80 total images (40 presented as word / 40 presented as text)

height = 1200;
width = 1600; %size of images
cd('E:\2D_Semantic_CVI') %work desktop
% cd('C:\KerriWork\2D_Image') %home desktop

for g = 1:2 %run for both groups: CVI and Control
    %load appropriate data
    if g==1
        %Control
        fnames = dir('E:\2D_Semantic_CVI\Semantic_Raw_Data\control');
        cd('E:\2D_Semantic_CVI\Semantic_Raw_Data\control')
%         fnames = dir('C:\KerriWork\2D_Image\2D_Controls');
%         cd('C:\KerriWork\2D_Image\2D_Controls')

    else
        %CVI
        fnames = dir('E:\2D_Semantic_CVI\Semantic_Raw_Data\CVI')
        cd('E:\2D_Semantic_CVI\Semantic_Raw_Data\CVI')
%         fnames = dir('C:\KerriWork\2D_Image\2D_CVI')
%         cd('C:\KerriWork\2D_Image\2D_CVI')
    end

    fnames = {fnames.name};
    fnames = fnames(3:end); %remove . and ..

    for s = 1:length(fnames) %for all subjects
        s
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
        
        if g==1 && contains(fnames(s),'Img')
            conImg(s,:) = trialData;
        elseif g==1 && contains(fnames(s),'Txt')
            conTxt(s,:) = trialData;
        elseif g==2 && contains(fnames(s),'Img')
            cviImg(s,:) = trialData;
        elseif g==2 && contains(fnames(s),'Txt')
            cviTxt(s,:) = trialData;
        end      
        
    end      
end

conImg = conImg(~cellfun('isempty',conImg))
conTxt = conTxt(~cellfun('isempty',conTxt))
cviImg = cviImg(~cellfun('isempty',cviImg))
cviTxt = cviTxt(~cellfun('isempty',cviTxt))

%% Plot

%large appended mat of position data for all subjects/trial in controlImg
conImgPos = [];
for c = 1:length(conImg)
    data = conImg{c};
    appPos = data(:,2:3);
    conImgPos = [conImgPos;appPos];
end
%large appended mat of position data for all subjects/trial in controlTxt
conTxtPos = [];
for c = 1:length(conTxt)
    data = conTxt{c};
    appPos = data(:,2:3);
    conTxtPos = [conTxtPos;appPos];
end
%large appended mat of position data for all subjects/trial in cviImg
cviImgPos = [];
for c = 1:length(cviImg)
    data = cviImg{c};
    appPos = data(:,2:3);
    cviImgPos = [cviImgPos;appPos];
end
%large appended mat of position data for all subjects/trial in cviTxt
cviTxtPos = [];
for c = 1:length(cviTxt)
    data = cviTxt{c};
    appPos = data(:,2:3);
    cviTxtPos = [cviTxtPos;appPos];
end
    
fig = figure

%%% conImg %%%

%imagesc hist
x=0:0.01:1; y=x; % generate (x,y) bins, with 100 steps
    
%normalize on a scale from 0 to 1 based on window size
normX = conImgPos(:,1)./width; 
normY = conImgPos(:,2)./height;

H = hist3([normX,normY],{x,y}); % create a 2D histogram of eye positions    
gaussFilt=fspecial('gaussian',[9 1],2); % create gaussian filter with standard deviation of 2 pixels
H=conv2(gaussFilt,gaussFilt',H,'same'); % smooth eye histogram
H = imresize(H,[width,height]); %resize to image size

subplot(2,2,1)
imagesc(H', 'AlphaData',.8)
title('Control Image')
axis off;

%%% conTxt %%%

%imagesc hist
x=0:0.01:1; y=x; % generate (x,y) bins, with 100 steps
    
%normalize on a scale from 0 to 1 based on window size
normX = conTxtPos(:,1)./width; 
normY = conTxtPos(:,2)./height;

H = hist3([normX,normY],{x,y}); % create a 2D histogram of eye positions    
gaussFilt=fspecial('gaussian',[9 1],2); % create gaussian filter with standard deviation of 2 pixels
H=conv2(gaussFilt,gaussFilt',H,'same'); % smooth eye histogram
H = imresize(H,[width,height]); %resize to image size

subplot(2,2,2)
imagesc(H', 'AlphaData',.8)
title('Control Text')
axis off;

%%% cviImg %%%

%imagesc hist
x=0:0.01:1; y=x; % generate (x,y) bins, with 100 steps
    
%normalize on a scale from 0 to 1 based on window size
normX = cviImgPos(:,1)./width; 
normY = cviImgPos(:,2)./height;

H = hist3([normX,normY],{x,y}); % create a 2D histogram of eye positions    
gaussFilt=fspecial('gaussian',[9 1],2); % create gaussian filter with standard deviation of 2 pixels
H=conv2(gaussFilt,gaussFilt',H,'same'); % smooth eye histogram
H = imresize(H,[width,height]); %resize to image size

subplot(2,2,3)
imagesc(H', 'AlphaData',.8)
title('CVI Image')
axis off;

%%% cviTxt %%%

%imagesc hist
x=0:0.01:1; y=x; % generate (x,y) bins, with 100 steps
    
%normalize on a scale from 0 to 1 based on window size
normX = cviTxtPos(:,1)./width; 
normY = cviTxtPos(:,2)./height;

H = hist3([normX,normY],{x,y}); % create a 2D histogram of eye positions    
gaussFilt=fspecial('gaussian',[9 1],2); % create gaussian filter with standard deviation of 2 pixels
H=conv2(gaussFilt,gaussFilt',H,'same'); % smooth eye histogram
H = imresize(H,[width,height]); %resize to image size

subplot(2,2,4)
imagesc(H', 'AlphaData',.8)
title('CVI Text')
axis off;
