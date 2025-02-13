%% Kernel density estimates for 2D Semantic
%kernel density function creates a contour plot, area of the polygons gives
%an estimate of scatter area 

addpath('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI')

% cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\control')
% fnames = dir('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\control');
cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\cvi')
fnames = dir('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\cvi');

fnames = {fnames.name};
fnames = fnames(3:end);

for f=1:length(fnames)
    DATA = readtable(char(fnames(f)));

    height = 540;
    width = 720; %size of images

    trialData = {};

    tri = table2array(DATA(2:end,1)); %trials
    cali = table2array(DATA(2:end,9)); %calibration marker
    time = table2array(DATA(2:end,3)); %trial time
    eyeX = table2array(DATA(2:end,4)); %Xpos
    eyeY = table2array(DATA(2:end,5)); %Ypos
    vis = table2array(DATA(2:end,10)); %target visable

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

    %clean data
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

    scatterArea = zeros(1,40); %preallocate scatterArea matrix for 40 trials

    %note: if running in a loop, plots will close after each iteration (so
    %matlab can handle finding new contours)
    for i = 1:40

        data = trialData{i};

        eyeX = data(:,2);
        eyeY = data(:,3);        
        eyeData = [eyeX,eyeY];

%         figure
%         scatter(eyeData(:,1),eyeData(:,2))
%         xlabel('Xpos')
%         ylabel('Ypos')
%         title('2D Gaze Plot')
%         set(gca, 'YDir','reverse')
% 
%         figure
%         [f,xi,bw1] = ksdensity(eyeData); %find default bandwidth
%         ksdensity(eyeData) %plot
%         xlabel('Xpos')
%         ylabel('Ypos')
%         zlabel('Density (Frequency)')
%         title('Kernel Density Estimate')
%         set(gca, 'YDir','reverse')

%         %calculate center offset
%         idx = find(f==max(f)); %find index of max peak
%         centroid = xi(idx,:); %x and y location of centroid
%         c = [width/2, height/2]; %center of image
%         cDist(i) = sqrt((c(1)-centroid(1)).^2 + (c(2)-centroid(2)).^2); %distance of highest peak from center of image (note this is center of screen, not necessarily center of object)

        figure()
        ksdensity(eyeData,'PlotFcn','contour'); %plot the contour 
        %note: when doing these next steps, make sure no old contour plots are
        %open - will mess with matlab trying to find the objects
        %("close all" later will handle this when running in a loop)

        obj = findobj('Type','contour'); %grab coordinates from the plotted contour
        [cc, h] = contour(obj.XData, obj.YData, obj.ZData); %reorganize as a matlab contour shape (easier to work with in matlab syntax)

        contourTable = getContourLineCoordinates(cc); %use github function to arrange contour coordinates as a table (super convenient, thanks Adam Danz!) 

        hold on

        L = 1; %we want contours in level 1 (largest contours)
        if h.LevelList(1) == 0 %but won't work if 1st contour level is 0, go to next
            L=L+1;
        end
        levelIdx = contourTable.Level == h.LevelList(L); %we want contours in level 1 (largest contours)
        if h.LevelList(1) == 0 
           levelIdx = contourTable.Level == h.LevelList(L);
        end
        plot(contourTable.X(levelIdx), contourTable.Y(levelIdx), 'r.', 'MarkerSize', 10); %plot this level to double check it's grabbing what we want
        set(gca, 'YDir','reverse')

        rows = contourTable.Level==h.LevelList(L); %rows of contour table for largest contour
        groups = unique(contourTable.Group(rows)); %find how many individual polygons
        a = zeros(1,length(groups)); %preallocate an area vector

        figure()
        for g = 1:length(groups) %go through for each polygon
            group = contourTable.Group==groups(g); %which polygon
            x=contourTable.X(rows&group); %x coordinates for this polygon
            y=contourTable.Y(rows&group); %y coordinates for this polygon

            p = polyshape(x,y); %make this a matlab polygon
            plot(p) %check
            hold on

            a(g) = area(p); %find area of polygon, save each polygon area seperate
        end
        set(gca, 'YDir','reverse')

        scatterArea(i) = sum(a); %sum all polygon areas for scatter area
        close all %close figures
    end
%     scatterArea_control(f,:) = scatterArea;
    scatterArea_cvi(f,:) = scatterArea;
end

%% Stats

histogram(mean(scatterArea_control,2),'BinWidth',10000,'FaceColor','r','FaceAlpha', 0.5)
hold on
histogram(mean(scatterArea_cvi,2),'BinWidth',10000,'FaceColor','b','FaceAlpha', 0.5)
ylabel('Count')
xlabel('Scatter Area (Pixels)')
legend('Control', 'CVI')

%shouldn't do ttest... non-normal stats
[h,p,ci,stats] = ttest2(mean(scatterArea_control,2),mean(scatterArea_cvi,2))

%non-parametric test (Wilcoxon rank sum)
[p,h,stats] = ranksum(mean(scatterArea_control,2),mean(scatterArea_cvi,2))

control = mean(scatterArea_control,2)
cvi = [mean(scatterArea_cvi,2);NaN;NaN;NaN] %even out the lengths
boxplot([control,cvi],'Labels',{'Control','CVI'})
ylabel('Scatter Area (Pixels)')