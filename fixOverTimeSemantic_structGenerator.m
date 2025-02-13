%% Fix over time Semantic

load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\GBVS_Heatmaps')
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\GloVe_Heatmaps_TargetObject')
% load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\original80_final4_withEdits_OneWord.mat')

addpath('E:\2D_Image_CVI\FixationClassification')

%% Calculate AUC scores for all trials

imheight = 1200;
imwidth = 1600; %size of images
    
for g = 1:2 %control vs CVI
    
    if g==1
        cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\control')
    else
        cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\CVI')
    end
    fileNames = dir
    fileNames = {fileNames.name}
    fileNames = fileNames(3:end)
    
    for subj=1:length(fileNames)
        subj
        
        salVal = [];
        semVal = [];
        
        DATA = readtable(char(fileNames(subj))); %load the files one by one

        trialData = {};

        tri = table2array(DATA(2:end,1)); %trials
        time = table2array(DATA(2:end,2)); %time
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
                temp = [time(tri==n),eyeX(tri==n),eyeY(tri==n)]; %temporary matrix
                trialData{1,n} = temp(idx:end,:); %final matrix (values only after stimulus presentation)
            end
        end
        trialData = trialData(~cellfun('isempty',trialData)); %remove empty (calibration) cells

        for t=1:length(trialData)
            %convert times to "frames" (use sequential numbers instead of fractioned seconds for accuracy in NonParaFixLab)
            data = trialData{1,t};
            data(:,1) = [1:length(data)]';

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
    
        %label fixations with Foster's function
        [PoG_samples_withfixlabels, opt_duration_thresh, opt_speed_thresh] = NonParaFixLab(trialData);

        fixNum = zeros(1,length(PoG_samples_withfixlabels)); %preallocate fixNum vector
        for f=1:length(PoG_samples_withfixlabels) 
            sample = PoG_samples_withfixlabels{f}; %go through samples one by one

            fixNum(f) = length(find(sample(:,5)==1 & circshift(sample(:,5),1)==0)); %find the first 1s in a sequence
            if sample(1,5)==1 & sample(end,5)==1 %if trial started and ended with fixations the above line will mash them together as 1, add a fixation to counteract this
                fixNum(f) = fixNum(f)+1;
            end
        end

        C = {'r','g','m','y','c','k','b'}; %color vector for plotting

        % parse through
        for t=1:length(PoG_samples_withfixlabels)
            clear fixStart;clear fixEnd;clear saccStart; clear saccEnd;
            sample = PoG_samples_withfixlabels{t}; %go through samples one by one
            nfix=[];
            vsacc=[];
            dsacc=[];
            c=1; %counter

%             figure; hold on
%             scatter(sample(:,2),sample(:,3),'bx');
%             plot(sample(:,2),sample(:,3));
%             xlabel('Xpos')
%             ylabel('Ypos')
%             title('2D Gaze Plot CVI')

            for n=1:size(sample,1) %go through each gaze point
%                 if n==1 & sample(n,5)==1 %if first datapoint is a fix
%                    fixStart = sample(n,1);                  
%                 elseif sample(n,5)==1 & sample(n-1,5)==0 %find a first 1 in a sequence
%                     fixStart = sample(n,1);
%                 end
%                 if n==size(sample,1) & sample(n,5)==1 %if last datapoint is a fix
%                    fixEnd = sample(n,1);                  
%                 elseif sample(n,5)==1 & sample(n+1,5)==0 %find last 1 in a sequence
%                    fixEnd = sample(n,1);
%                 end
                
                if n==1 & sample(n,5)==0 %if first datapoint is a sacc
                   saccStart = sample(n,1);                  
                elseif sample(n,5)==0 & sample(n-1,5)==1 %find a first 0 in a sequence
                    saccStart = sample(n,1);
                end
                if n==size(sample,1) & sample(n,5)==0 %if last datapoint is a sacc
                   saccEnd = sample(n,1);                  
                elseif sample(n,5)==0 & sample(n+1,5)==1 %find last 0 in a sequence
                   saccEnd = sample(n,1);
                end
                
%                 if exist('fixStart','var')==1 & exist('fixEnd','var')==1 %skip until we find a fixation start and fixation end
%                    while isnan(sample(fixStart,4)) | isnan(sample(fixStart,2:3)) %don't use starting points with nonexisting velocity or position values
%                       fixStart = fixStart+1; %use next point with velocity and position
%                       if fixStart > length(sample) %if we try to find a starting point past the point where the trial ends, ignore this last starting point (must be full of NaNs)
%                          break
%                       end
%                    end
%                    while isnan(sample(fixEnd,4)) | isnan(sample(fixEnd,2:3)) %don't use ending points with nonexisting velocity or position values
%                       fixEnd = fixEnd-1; %use last point with velocity and position
%                       if fixEnd == 0 %if we try to find an ending point before the trial begins, ignore this first ending point(must be full of NaNs)
%                           break
%                       end
%                    end
%                    
%                    nfix(c,1) = nanmean(sample(fixStart:fixEnd,2)); %average x pos during fix
%                    nfix(c,2) = nanmean(sample(fixStart:fixEnd,3)); %average y pos during fix
%                    
%                    % scatter(sample(fixStart:fixEnd,2),sample(fixStart:fixEnd,3),C{c},'x')
% %                    set(gca, 'YDir','reverse')
% 
%                    clear fixStart;clear fixEnd;
%                    c=c+1; %next color
%                 end
                
               if exist('saccStart','var')==1 & exist('saccEnd','var')==1 %skip until we find a sacc start and sacc end
                   if saccStart == saccEnd %if sacc is 1 point (with NaNs) ignore it
                      clear saccStart; clear saccEnd;
                   else
                       while isnan(sample(saccStart,2:3)) %don't use starting points with nonexisting position values
                          saccStart = saccStart+1; %use next point with position
                          if saccStart > length(sample) %if we try to find a starting point past the point where the trial ends, ignore this last starting point (must be full of NaNs)
                             break
                          end
                       end
                       while isnan(sample(saccEnd,4)) | isnan(sample(saccEnd,2:3)) %don't use ending points with nonexisting velocity or position values
                          saccEnd = saccEnd-1; %use last point with velocity and position
                          if saccEnd == 0 %if we try to find an ending point before the trial begins, ignore this first ending point(must be full of NaNs)
                              break
                          end
                       end

                       nsacc(t) = c; %number of saccs
                       vsacc(c) = max(sample(saccStart:saccEnd,4)); %greatest velocity of this sacc
                       d = [sample(saccStart,2:3);sample(saccEnd,2:3)];
                       dsacc(c) =  pdist(d,'euclidean'); %average distance of this sacc

                       clear saccStart; clear saccEnd;
                       c=c+1; %next color
                   end
               end
               
                if isempty(vsacc)
                    vsacc = NaN;
                    dsacc = NaN;
                end            
               
            end
            
            avgNsacc = nanmean(nsacc);
            avgVsacc(t) = nanmean(vsacc);
            avgDsacc(t) = nanmean(dsacc);
            
        end
        
%             %if no fixations, use NaNs
%             if isempty(nfix)
%                 nfix(1,1) = NaN;
%                 nfix(1,2) = NaN;
%             end
                       
            
%             % SALIENCE STUFF
%             currIm = image{t}; %name of current image
%             myImage = imread(sprintf('C:\\Users\\Kerri\\Dropbox\\Kerri_Walter\\2D_Semantic_CVI\\imagesNumeric\\%s.jpg',currIm)); %load in this image
%             myImage = imresize(myImage,[imheight,imwidth]);
%             mapIdx = find(strcmp(GBVSLibrary(3,:),currIm)); %index of current image in map library (index same for GBVS and GloVe)
%             origName = GBVSLibrary(1,mapIdx); %original file name
%             
%             gbvsmap = GBVSLibrary{2,mapIdx}; %gbvs map      
%             glovemap = GloVeLibrary{2,mapIdx}; %glove map      
% 
%             for f = 1:length(nfix(:,1))
%             
%                 curFix = round(nfix(f,:)); %current fixation coordinates by closest pixel
% %                 curFix(curFix==0) = 1; %if a pixel rounded down to 0 (right on the edge), change it to 1 so we don't encounter a 0 map error
% 
%                 if ~isnan(curFix)
%                     salVal(t,f) = gbvsmap(curFix(2),curFix(1)); %find the gbvs value at this point
%                 else
%                     salVal(t,f) = NaN; %if it's a nan just placehold a nan
%                 end
% 
%                 if ~isnan(curFix)
%                    semVal(t,f) = glovemap(curFix(2),curFix(1)); %find the glove value at this point
%                 else
%                    semVal(t,f) = NaN; %if it's a nan just placehold a nan
%                 end
% 
% %                 imagesc(glovemap); hold on
% %                 plot(curFix(1),curFix(2),'or', 'LineWidth', 2)
%            end
%         
%             %change the ending 0s in our grid to NaNs so we can divide later  
%             salVal(salVal == 0) = NaN;
%             semVal(semVal == 0) = NaN;
%             
% %             scatter(nfix(:,1),nfix(:,2),'bo','filled')
%          end
%         
%         if g==1
%             fixSalSemControl.(sprintf('Sub%d', subj)).salVal = salVal;
%             fixSalSemControl.(sprintf('Sub%d', subj)).semVal = semVal;
%         elseif g==2
%             fixSalSemCVI.(sprintf('Sub%d', subj)).salVal = salVal;
%             fixSalSemCVI.(sprintf('Sub%d', subj)).semVal = semVal;    
%         end

        if g==1
            NsaccControl(subj) = avgNsacc;
            VsaccControl(subj) = nanmean(avgVsacc);
            DsaccControl(subj) = nanmean(avgDsacc);
        elseif g==2
            NsaccCVI(subj) = avgNsacc;
            VsaccCVI(subj) = nanmean(avgVsacc);
            DsaccCVI(subj) = nanmean(avgDsacc);    
        end
    end
end

[h,p,ci,stats] = ttest2(NsaccControl,NsaccCVI) %number of saccades is different (expected bc num of fix) (t(59) = -6.634, p < .001)
[h,p,ci,stats] = ttest2(VsaccControl,VsaccCVI) %velocity is not different  (t(59) = -1.685, p=.097) 
[h,p,ci,stats] = ttest2(DsaccControl,DsaccCVI) %distance is not different  (t(59) = -0.3623, p=.718) 

figure
subplot(1,3,1)
x = [NsaccControl';NsaccCVI'];
g = [zeros(32, 1); ones(29, 1)];
boxplot(x,g,'Labels',{'Control','CVI'})
title('Number of Saccades')
ylabel('Average Number')
subplot(1,3,2)
x = [VsaccControl';VsaccCVI'];
boxplot(x,g,'Labels',{'Control','CVI'})
title('Velocity of Saccades')
ylabel('Average Velocity (pixel/frame)')
subplot(1,3,3)
x = [DsaccControl';DsaccCVI'];
boxplot(x,g,'Labels',{'Control','CVI'})
title('Distance of Saccades')
ylabel('Average Distance (pixels)')

%% organize into a readable table for a mixed linear model

fixTableControl = table
for sj=1:32   
    wc1 = fixSalSemControl.(sprintf('Sub%d', sj)); %working channel subj level
    for s = 1:2 %for 2 sem/sal conditions
        salsem = ["salVal","semVal"]; %sal\sem names
        wc3 = fixSalSemControl.(sprintf('Sub%d', sj)).(salsem(s)); %working channel sal\sem level
        for f = 1:size(wc3,2) %for N fixation numbers (variable per subj)
            subj = repmat(sj,size(wc3,1),1); %string of subj number
            fixNum = repmat(f,size(wc3,1),1); %string of fixation values
            salsem = repmat(salsem(s),size(wc3,1),1); %string of salsem condition
            val = wc3(:,f); %values

            table2 = table(subj,fixNum,salsem,val); %table of this run
            fixTableControl = [fixTableControl;table2]; %append to full table
        end
    end
end
fixTableControl(any(ismissing(fixTableControl),2),:) = [] %remove nans

fixTableCVI = table
for sj=1:29
    wc1 = fixSalSemCVI.(sprintf('Sub%d', sj)); %working channel subj level
    for s = 1:2 %for 2 sem/sal conditions
        salsem = ["salVal","semVal"]; %sal\sem names
        wc3 = fixSalSemCVI.(sprintf('Sub%d', sj)).(salsem(s)); %working channel sal\sem level
        for f = 1:size(wc3,2) %for N fixation numbers (variable per subj)
            subj = repmat(sj,size(wc3,1),1); %string of subj number
            fixNum = repmat(f,size(wc3,1),1); %string of fixation values
            salsem = repmat(salsem(s),size(wc3,1),1); %string of salsem condition
            val = wc3(:,f); %values

            table2 = table(subj,fixNum,salsem,val); %table of this run
            fixTableCVI = [fixTableCVI;table2]; %append to full table
        end
    end
end
fixTableCVI(any(ismissing(fixTableCVI),2),:) = [] %remove nans