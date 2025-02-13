cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC')
% sceneDes = readtable('semanticCVISceneDescriptions.xls'); %scene descriptions
targObj = readtable('semanticCVITargetObjects.xlsx');%target object

%load in the glove set
cd('E:\GloVe-master\GloVe')
glovefile = "glove.840B.300d";
if exist(glovefile + '.mat', 'file') ~= 2
    emb = readWordEmbedding(glovefile + '.txt');
    save(glovefile + '.mat', 'emb', '-v7.3');
else
    load(glovefile + '.mat')
end

%load annotation set 
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\original80_final4_withEdits_OneWord.mat')

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
GloVeLibrary = {};

for f = 1:80
    f
    fileNameFull = fileNames{f};
    fileNameShort = erase(fileNameFull,'.jpg');
    myImage = imread(fileNameFull);
    
    %find filename in annotation struct
    for s=1:80
        if strcmp(struct80EditsOneWord(s).annotation.filename, fileNameFull)
           a = s; %annotation index variable
        end
    end
    
    %% GloVe

%     queryList = sceneDes.(fileNameShort);
    queryList = targObj.(fileNameShort);
    [semanticIm] = GloVeSemanticCVI(fileNameShort, myImage, queryList, emb, struct80EditsOneWord, a); %get the GloVe (semantic relevance) map
    GloVeFilt = imresize(semanticIm,[height,width]);  %resize filter to fit our smaller experiment picture
    GloVeFilt = imgaussfilt(GloVeFilt,pxError); %add a gaussian of the eyetracker error
    GloVeFilt = (GloVeFilt - min(GloVeFilt(:))) / (max(GloVeFilt(:)) - min(GloVeFilt(:))); %normalize
   
%     figure()
%     imagesc(GloVeFilt)
    
    GloVeLibrary(1,f) = {fileNameShort}; 
    GloVeLibrary(2,f) = {GloVeFilt}; 
    
end

SAVE = 'C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC';
cd(SAVE)
savefile = 'GloVe_Heatmaps_TargetObject';
save(savefile,'GloVeLibrary')