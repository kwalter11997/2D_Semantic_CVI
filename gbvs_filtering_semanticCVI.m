addpath(genpath('E:\SceneProcessing\Meaning_Salience_Maps\gbvs'))

cd('E:\2D_Semantic_CVI\images')
% cd('E:\SceneProcessing\FinalLibrary\images\all')
D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these
fileNames = {D.name}; %get all the file names
 
height = 1200;
width = 1600; %size of images

%screen info
scrnWidthPx = 1920; %screen width pixels
scrnWidthCm = 60; %screen width cm
viewDistCm = 63; %viewing distance of participants
%get visual angle info for error that should be applied via gaussian
scrnWidthDeg=2*atand((0.5*scrnWidthCm)/viewDistCm); %calculate screen width in degrees
pxperdeg = scrnWidthPx/scrnWidthDeg; %get number of pixels per degree
pxError = .375*pxperdeg; %multiply pixel per degree by average degree error (.375 taken from estimate of 0.25-0.50 from Eyelink Manual) to get the number of pixels in the estimated manufacturer error

%create some empty variables to save the maps in later
GBVSLibrary = {};

for f = 1:80
    f
    fileNameFull = fileNames{f};
    fileNameShort = erase(fileNameFull,'.jpg');
    myImage = imread(fileNameFull);
    
    %% gbvs
           
    out_gbvs = gbvs(myImage); 
    gbvsFilt = imresize(out_gbvs.master_map_resized, [height,width]); %resize so it's how it appeared in the experiment    
    gbvsFilt = imgaussfilt(gbvsFilt,pxError); %add a gaussian of the eyetracker error       
    gbvsFilt = (gbvsFilt - min(gbvsFilt(:))) / (max(gbvsFilt(:)) - min(gbvsFilt(:))); %normalize
         
    figure()
    imagesc(gbvsFilt)
 
    GBVSLibrary(1,f) = {fileNameShort}; 
    GBVSLibrary(2,f) = {gbvsFilt}; 
    
end

SAVE = 'C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC';
cd(SAVE)
savefile = 'GBVS_Heatmaps';
save(savefile,'GBVSLibrary')
