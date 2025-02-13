addpath('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI')

%% holders
objNum = zeros(1,80);
ent = zeros(1,80);
fracDim = zeros(1,80);
edgeSum = zeros(1,80);

for i = 1:80
    cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\images')
    filename = struct80EditsOneWord(i).annotation.filename;
    img = imread(filename);
    fileorder(i) = {filename};
    
    %number of objects
    objNum(i) = length(struct80EditsOneWord(i).annotation.object)
    
    %entropy
    ent(i) = entropy(img)

    %fractal dimension
    myIm=double(rgb2gray(img)); % convert to floating point grayscale
    gaussSigma=0.5; % a list of values for the standard deviation of the Gaussian filter
    myFilter=fspecial('gaussian', [6*gaussSigma 6*gaussSigma], gaussSigma); % create filter kernel
    myImFilt=imfilter(double(myIm),myFilter);
%     imagesc(myImFilt); % plot the local mean luminance
    myImFilt=myImFilt>mean(myImFilt(:)); % convert to black white binary image
    fdEst=fractDBoxCount(myImFilt, 0);
%     imagesc(myImFilt); % plot the local mean luminance
%     colormap('gray'); % lightness increases with contrast value
%     title(sprintf('Sigma = %.2f pixels, FD = %.3f',gaussSigma, fdEst(1))); % give the figure a title
%     axis off
    fracDim(i) = fdEst(1)

    %edge sum
    e = edge(myIm, 'log');
    edgeSum(i) = sum(e(:))
    
end

%% Plot

figure()

subplot(2,2,1)
%bar(objNum)
hist(objNum)
xlabel('Number of Objects')
ylabel('Frequency')
% title('Number of Objects')

subplot(2,2,2)
%bar(ent)
hist(ent)
xlabel('Entropy')
ylabel('Frequency')
% title('Entropy')

subplot(2,2,3)
%bar(fracDim)
hist(fracDim)
xlabel('Fractal Dimension')
ylabel('Frequency')
% title('Fractal Dimension')

subplot(2,2,4)
%bar(edgeSum)
hist(edgeSum)
xlabel('Number of Edges')
ylabel('Frequency')
% title('Number of Edges')

sgtitle('Measures of Environment Complexity')

%% organize AUC by complexity

load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\gbvsAUCCVI.mat')
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\gbvsAUCControl.mat')
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\gloveAUCCVI.mat')
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\gloveAUCControl.mat')

load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\GBVS_Heatmaps.mat') %this library has the correlation beteween datafile img names and annotation file img names
%replace original file names with datafile names
for f=1:80
    libIdx = find(strcmp(erase(fileorder(f),'.jpg'),GBVSLibrary(1,:)))
    fileorder(f) = GBVSLibrary(3,libIdx)
end

%easy sort    
[sortedFileorder, idx] = sort(fileorder) %sort arbitrarily (alphabetical)
sortedObjnum = objNum(idx) %all matricies will follow this sort
sortedEnt = ent(idx)
sortedFracdim = fracDim(idx)
sortedEdgesum = edgeSum(idx)

%Control
cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\control')

fileNames = dir
fileNames = {fileNames.name}
fileNames = fileNames(3:end)

c = 1; %simple counter
for subj=1:2:length(fileNames) %grabbing every 2 files at once
    subj
    DATA1 = readtable(char(fileNames(subj))); %load the files one by one
    subjorder1 = unique(table2array(DATA1(2:end,7)),'stable')'; %image viewed
    subjorder1(1) = []; %remove NA from image vector
    %need both subj files to get all 80 images 
    DATA2 = readtable(char(fileNames(subj+1))); %load the files one by one
    subjorder2 = unique(table2array(DATA2(2:end,7)),'stable')'; %image viewed
    subjorder2(1) = []; %remove NA from image vector
    
    subjorder = [subjorder1,subjorder2] %all 80 images
    [sortedSubjorder, subjidx] = sort(subjorder) %this sort will match filesort (alphabetical)
    
    toselectgbvs = gbvsAUCControl(subj:subj+1,:);
    toselectgbvs = toselectgbvs(:)';
    sortedGBVSControl(c,:) = toselectgbvs(subjidx)
    
    toselectglove = gloveAUCControl(subj:subj+1,:);
    toselectglove = toselectglove(:)';
    sortedGloVeControl(c,:) = toselectglove(subjidx)
    
    c = c+1;
end

%CVI
cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\Semantic_Raw_Data\CVI')

fileNames = dir
fileNames = {fileNames.name}
fileNames = fileNames(3:end)

fileNames(5) = []; %don't run the subj who only has half the images

c = 1; %simple counter
toselectgbvs=[];
toselectglove=[];
for subj=1:2:length(fileNames) %grabbing every 2 files at once
    subj
    DATA1 = readtable(char(fileNames(subj))); %load the files one by one
    subjorder1 = unique(table2array(DATA1(2:end,7)),'stable')'; %image viewed
    subjorder1(1) = []; %remove NA from image vector
    %need both subj files to get all 80 images 
    DATA2 = readtable(char(fileNames(subj+1))); %load the files one by one
    subjorder2 = unique(table2array(DATA2(2:end,7)),'stable')'; %image viewed
    subjorder2(1) = []; %remove NA from image vector
    
    subjorder = [subjorder1,subjorder2] %all 80 images
    [sortedSubjorder, subjidx] = sort(subjorder) %this sort will match filesort (alphabetical)
    
    toselectgbvs = gbvsAUCCVI(subj:subj+1,:);
    toselectgbvs = toselectgbvs(:)';
    sortedGBVSCVI(c,:) = toselectgbvs(subjidx)
    
    toselectglove = gloveAUCCVI(subj:subj+1,:);
    toselectglove = toselectglove(:)';
    sortedGloVeCVI(c,:) = toselectglove(subjidx)
    
    c = c+1;
end

%% Correlations

%Control GBVS

%num objs
subplot(2,2,1)
scatter(sortedObjnum,mean(sortedGBVSControl))
xlabel('Number of Objects')
ylabel('GBVS ROC')
title('Number of Objects')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(70,.76, 'y = 1.7325e-04x + 0.7976')
mdl = fitlm(sortedObjnum,mean(sortedGBVSControl))
text(70,.75, 'R^2 = 0.0123, p = .3271')
%ent
subplot(2,2,2)
scatter(sortedEnt,mean(sortedGBVSControl))
xlabel('Entropy')
ylabel('GBVS ROC')
title('Entropy')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(7.05,.76, 'y = -0.0068x + 0.8576')
mdl = fitlm(sortedEnt,mean(sortedGBVSControl))
text(7.05,.75, 'R^2 = 0.0012, p = .761')
%fracdim
subplot(2,2,3)
scatter(sortedFracdim,mean(sortedGBVSControl))
xlabel('Fractal Dimension')
ylabel('GBVS ROC')
title('Fractal Dimension')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(1.105,.87, 'y = 0.0606x + 0.7164')
mdl = fitlm(sortedFracdim,mean(sortedGBVSControl))
text(1.105,.86, 'R^2 = 0.0322, p = .111')
%edgesum
subplot(2,2,4)
scatter(sortedEdgesum,mean(sortedGBVSControl))
xlabel('Edge Sum')
ylabel('GBVS ROC')
title('Edge Sum')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(3e5,.87, 'y = 2.5144-08x + 0.8014')
mdl = fitlm(sortedEdgesum,mean(sortedGBVSControl))
text(3e5,.86, 'R^2 = 0.0055, p = .513')

sgtitle('Control GBVS')

%Control GloVe
figure
%num objs
subplot(2,2,1)
scatter(sortedObjnum,mean(sortedGloVeControl))
xlabel('Number of Objects')
ylabel('GloVe ROC')
title('Number of Objects')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(70,.73, 'y = 3.2972e-04x + 0.7708')
mdl = fitlm(sortedObjnum,mean(sortedGloVeControl))
text(70,.72, 'R^2 = 0.0233, p = .176')
%ent
subplot(2,2,2)
scatter(sortedEnt,mean(sortedGloVeControl))
xlabel('Entropy')
ylabel('GloVe ROC')
title('Entropy')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(7.05,.73, 'y = .0019x + 0.7713')
mdl = fitlm(sortedEnt,mean(sortedGloVeControl))
text(7.05,.72, 'R^2 = 5.1000e-05, p = .950')
%fracdim
subplot(2,2,3)
scatter(sortedFracdim,mean(sortedGloVeControl))
xlabel('Fractal Dimension')
ylabel('GloVe ROC')
title('Fractal Dimension')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(1.105,.89, 'y = 0.0674x + 0.6868')
mdl = fitlm(sortedFracdim,mean(sortedGloVeControl))
text(1.105,.88, 'R^2 = 0.0209, p = .201')
%edgesum
subplot(2,2,4)
scatter(sortedEdgesum,mean(sortedGloVeControl))
xlabel('Edge Sum')
ylabel('GloVe ROC')
title('Edge Sum')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(3e5,.89, 'y = -1.2963e-08x + 0.7883')
mdl = fitlm(sortedEdgesum,mean(sortedGloVeControl))
text(3e5,.88, 'R^2 = 0.0008, p = .808')

sgtitle('Control GloVe')

%CVI GBVS
figure
%num objs
subplot(2,2,1)
scatter(sortedObjnum,mean(sortedGBVSCVI))
xlabel('Number of Objects')
ylabel('GBVS ROC')
title('Number of Objects')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(70,.68, 'y = -1.4321-04x + 0.7500')
mdl = fitlm(sortedObjnum,mean(sortedGBVSCVI))
text(70,.67, 'R^2 = 0.0094, p = .392')
%ent
subplot(2,2,2)
scatter(sortedEnt,mean(sortedGBVSCVI))
xlabel('Entropy')
ylabel('GBVS ROC')
title('Entropy')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(7.05,.68, 'y = -0.0378x + 1.0336')
mdl = fitlm(sortedEnt,mean(sortedGBVSCVI))
text(7.05,.67, 'R^2 = 0.0416, p = .069')
%fracdim
subplot(2,2,3)
scatter(sortedFracdim,mean(sortedGBVSCVI))
xlabel('Fractal Dimension')
ylabel('GBVS ROC')
title('Fractal Dimension')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(1.105,.68, 'y = -0.0397x + 0.8019')
mdl = fitlm(sortedFracdim,mean(sortedGBVSCVI))
text(1.105,.67, 'R^2 = 0.0155, p = .271')
%edgesum
subplot(2,2,4)
scatter(sortedEdgesum,mean(sortedGBVSCVI))
xlabel('Edge Sum')
ylabel('GBVS ROC')
title('Edge Sum')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(3e5,.68, 'y = 3.4892e-09x + 0.7428')
mdl = fitlm(sortedEdgesum,mean(sortedGBVSCVI))
text(3e5,.67, 'R^2 = .0001, p = .924')

sgtitle('CVI GBVS')

%CVI GloVe
figure
%num objs
subplot(2,2,1)
scatter(sortedObjnum,mean(sortedGloVeCVI))
xlabel('Number of Objects')
ylabel('GloVe ROC')
title('Number of Objects')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(5,.58, 'y = -3.35414e-04x + 0.6407')
mdl = fitlm(sortedObjnum,mean(sortedGloVeCVI))
text(5,.57, 'R^2 = 0.0267, p = .148')
%ent
subplot(2,2,2)
scatter(sortedEnt,mean(sortedGloVeCVI))
xlabel('Entropy')
ylabel('GloVe ROC')
title('Entropy')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(7.05,.58, 'y = -0.0254x + 0.8204')
mdl = fitlm(sortedEnt,mean(sortedGloVeCVI))
text(7.05,.57, 'R^2 = 0.0097, p = .384')
%fracdim
subplot(2,2,3)
scatter(sortedFracdim,mean(sortedGloVeCVI))
xlabel('Fractal Dimension')
ylabel('GloVe ROC')
title('Fractal Dimension')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(1.105,.58, 'y = -0.0990x + 0.7711')
mdl = fitlm(sortedFracdim,mean(sortedGloVeCVI))
text(1.105,.57, 'R^2 = 0.0497, p = .047*')
%edgesum
subplot(2,2,4)
scatter(sortedEdgesum,mean(sortedGloVeCVI))
xlabel('Edge Sum')
ylabel('GloVe ROC')
title('Edge Sum')
hl = lsline
B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
Slope = B(2)
Intercept = B(1)
text(3e5,.58, 'y = -2.6355e-08x + 0.6296')
mdl = fitlm(sortedEdgesum,mean(sortedGloVeCVI))
text(3e5,.57, 'R^2 = 0.0035, p = .603')

sgtitle('CVI GloVe')