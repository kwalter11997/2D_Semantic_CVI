%% TargetPresAbs all gaze SAL vs SEM analysis

load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\GBVS_Heatmaps')
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\GloVe_Heatmaps_TargetObject')
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\original80_final4_withEdits_OneWord.mat')

addpath(genpath('E:\SceneProcessing\Meaning_Salience_Maps\gbvs'))

%% Calculate AUC scores for all trials

imheight = 1200;
imwidth = 1600; %size of images
    
for c = 1:2 %control vs CVI
    
    gbvsAUCmat = [];
    gloveAUCmat = [];
    
    if c==1
        cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\control')
    else
        cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\CVI')
    end
    fileNames = dir
    fileNames = {fileNames.name}
    fileNames = fileNames(3:end)
    
    for subj=1:length(fileNames)
        subj
        DATA = readtable(char(fileNames(subj))); %load the files one by one

        trialData = {};

        tri = table2array(DATA(2:end,1)); %trials
        cali = table2array(DATA(2:end,9)); %calibration marker
        eyeX = table2array(DATA(2:end,4)); %Xpos
        eyeY = table2array(DATA(2:end,5)); %Ypos
        vis = table2array(DATA(2:end,10)); %target visable
        image = unique(table2array(DATA(2:end,7)),'stable'); %image viewed
        
        %remove calibration trials
        for n=1:max(tri)       
            if any(strcmp('Calibration',cali(tri==n,:))) %if this was a calibration trial
                continue
            else
                idx = find(strcmp('TargetVisible',vis(tri==n))); %index of where scene appears
                temp = [tri(tri==n),eyeX(tri==n),eyeY(tri==n)]; %temporary matrix
                trialData{1,n} = temp(idx:end,:); %final matrix (values only after stimulus presentation)
            end
        end
        trialData = trialData(~cellfun('isempty',trialData)); %remove empty (calibration) cells

        %clean data
        for t=1:length(trialData)
            data = trialData{1,t};

            offscreen = data(:,2)<0 | data(:,3)<0 | data(:,2)>1 | data(:,3)>1; %remove values outside 0 and 1 (offscreen) values
            data(offscreen,2:3) = NaN;          

            %reorganize gaze data in terms of pixels
            x = data(:,2);
            y = data(:,3);

            data(:,2) = round(imwidth*x); %scale according to image pixels
            data(:,3) = round(imheight*(1-y));
            
            trialData{1,t} = data;
        end
        image(1) = []; %remove NA from image vector
    
        for trial = 1:40
           
            currIm = image{trial}; %name of current image
            myImage = imread(sprintf('C:\\Users\\Kerri\\Dropbox\\Kerri_Walter\\2D_Semantic_CVI\\imagesNumeric\\%s.jpg',currIm)); %load in this image
            myImage = imresize(myImage,[imheight,imwidth]);
            mapIdx = find(strcmp(GBVSLibrary(3,:),currIm)); %index of current image in map library (index same for GBVS and GloVe)
            origName = GBVSLibrary(1,mapIdx); %original file name
            
            gbvsmap = GBVSLibrary{2,mapIdx}; %gbvs map      
            glovemap = GloVeLibrary{2,mapIdx}; %glove map      

            currTrial = trialData{trial};
%             
%             subplot(1,2,1);
%             imagesc(myImage)
%             hold on
%             imagesc(gbvsmap,'AlphaData',.7);
%             scatter(currTrial(:,2),currTrial(:,3),'rx')
%             subplot(1,2,2);
%             imagesc(myImage)
%             hold on
%             imagesc(glovemap,'AlphaData',.7);
%             scatter(currTrial(:,2),currTrial(:,3),'rx')
%             
            %outside target only
            for s = 1:80
                if strcmp(struct80EditsOneWord(s).annotation.filename, [char(origName) '.jpg'])
%                     s
                   targetAreaX = struct80EditsOneWord(s).annotation.targetCoords.x;
                   targetAreaY = struct80EditsOneWord(s).annotation.targetCoords.y;
                end
            end
            
%             figure
%             imagesc(myImage)
%             hold on
%             drawpolygon('Position',[targetAreaX,targetAreaY]);
     
            currX = currTrial(:,2);
            currY = currTrial(:,3);
            in = inpolygon(currX,currY,targetAreaX,targetAreaY);
            
%             plot(currX(in),currY(in),'r+') % points inside
%             plot(currX(~in),currY(~in),'bo') % points outside
            
            
            %% ROC analysis 
            %True Positive Rate:
            %Sensitivity = True Positives / (True Positives + False Negatives)
            %True Positive Rate = Sensitivity

            %False Positive Rate:
            %Specificity = True Negatives / (True Negatives + False Positives)
            %False Positive Rate = 1-Specificity     

            myFixIm = zeros(size(myImage)); % empty fixation image

            x=0:1:size(myImage,2)-1; %make x and y the size of the image
            y=0:1:size(myImage,1)-1;

%             myFixIm = hist3(currTrial(:,2:3),{x,y})'; %histogram of every pixel that was fixated       
            myFixIm = hist3([currX(~in),currY(~in)],{x,y})'; %histogram of every pixel that was fixated outside of target     
            
            [gbvsAUC] = AUC_Judd(gbvsmap, myFixIm, 0, 0);  
            [gloveAUC] = AUC_Judd(glovemap, myFixIm, 0, 0); 

            gbvsAUCmat(subj,trial) = gbvsAUC;
            gloveAUCmat(subj,trial) = gloveAUC;

        end
    end
    if c == 1
       gbvsAUCControl_noTarg = gbvsAUCmat;
       gloveAUCControl_noTarg = gloveAUCmat;
    else
       gbvsAUCCVI_noTarg = gbvsAUCmat;
       gloveAUCCVI_noTarg = gloveAUCmat;
    end
end

%% Stats
%between control/cvi / gbvs/glove
[h_gbvs,p_gbvs,ci_gbvs,stats_gbvs] = ttest2(mean(gbvsAUCControl,2),mean(gbvsAUCCVI,2))
[h_glove,p_glove,ci_glove,stats_glove] = ttest2(mean(gloveAUCControl,2),mean(gloveAUCCVI,2))

% %general sal vs sem
% [h,p,ci,stats] = ttest(subjAvgSal,subjAvgSem)
% d = computeCohen_d(subjAvgSal, subjAvgSem, 'paired')
% 
% %% plot
% 
% targsalsem = [absHavgSal',absLavgSal',absHavgSem',absLavgSem']
% 
% figure()
% coordLineStyle = 'r.';
% b2 = boxplot(targsalsem(:,3:4),'Symbol', coordLineStyle);hold on;
% % sig star for figure
% sigstar([1,2],p_glove) %only glove is sig
% b1 = boxplot(targsalsem(:,1:2),'Symbol', coordLineStyle,'Labels',{'High Semantic Salience','Low Semantic Salience'});
% 
% % colors = [1, .2, .2;1, .2, .2;.2, .2, 1;.2, .2, 1]
% colors = [.2, .2, 1;.2, .2, 1;1, .2, .2;1, .2, .2]
% h = findobj(gca,'Tag','Box');
% for j=1:length(h)
%     patch(get(h(j),'XData'),get(h(j),'YData'),colors(j,:),'FaceAlpha',.5);
% end
% ylim([0.4,0.8])
% 
% parallelcoords(targsalsem(:,1:2), 'Color', [.7 .7 1], 'LineStyle', '-',...
%   'Marker', '.', 'MarkerSize', 10);
% parallelcoords(targsalsem(:,3:4), 'Color', [1 .7 .7], 'LineStyle', '-',...
%   'Marker', '.', 'MarkerSize', 10);
% 
% plot([1,2],[nanmean(absHavgSal),nanmean(absLavgSal)],'Color','black','LineWidth',1.5)
% plot([1,2],[nanmean(absHavgSem),nanmean(absLavgSem)],'Color','black','LineWidth',1.5)
% 
% title('Average Image Salience and Semantic Salience AUC')
% ylabel('AUC')
% set(b1,{'linew'},{1}) %change boxplot line width
% set(b2,{'linew'},{1})
% lines = findobj(gcf, 'type', 'line', 'Tag', 'Median'); %change median line width
% set(lines,'LineWidth',2);
% 
% hold on
% g(1)=plot(NaN,NaN,'.','Color',[.2, .2, 1],'MarkerSize',20)
% g(2)=plot(NaN,NaN,'.','Color',[1, .2, .2],'MarkerSize',20)
% legend(g,'Image Salience','Semantic Salience')
% 
% 
% %% Effect size
% 
% effect = (mean(absHavgSal) - mean(absLavgSal)) / std(absHavgSal - absLavgSal)
% d = computeCohen_d(absHavgSal, absLavgSal, 'paired') %check for sanity
% 
% effect = (mean(absHavgSem) - mean(absLavgSem)) / std(absHavgSem - absLavgSem)
% d = computeCohen_d(absHavgSem, absLavgSem, 'paired') %check for sanity


