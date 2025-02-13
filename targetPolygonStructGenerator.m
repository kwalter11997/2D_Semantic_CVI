%% Create target image polygon structure

load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\GBVS_Heatmaps')
load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\GloVe_Heatmaps_TargetObject')

load('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\ROC\original80_final4_withEdits_OneWord.mat')

imheight = 1200;
imwidth = 1600; %size of images

 for trial = 1:80
           
    currIm = struct80EditsOneWord(trial).annotation.filename;
    myImage = imread(sprintf('C:\\Users\\Kerri\\Dropbox\\Kerri_Walter\\2D_Semantic_CVI\\images\\%s',char(currIm))); %load in this image
    origSize = size(myImage); %original size (for scaling of target coordinates)
    scaled = origSize(2)/imwidth; %same scale XandY (aspect ratio preserved)
    myImage = imresize(myImage,[imheight,imwidth]);
    target = struct80EditsOneWord(trial).annotation.target;  
    
    targIdx = find(strcmp({struct80EditsOneWord(trial).annotation.object.name},target));
    
%                    if length(targIdx) > 1 %words like "boots" being two seperate polygons but one single target
%                       targX1 = struct80(s).annotation.object(targIdx(1)).polygon.x; %target polygon1
%                       targY1 = struct80(s).annotation.object(targIdx(1)).polygon.y;
%                       targX2 = struct80(s).annotation.object(targIdx(2)).polygon.x; %target polygon2
%                       targY2 = struct80(s).annotation.object(targIdx(2)).polygon.y;
%                       targX3 = struct80(s).annotation.object(targIdx(3)).polygon.x; %target polygon1
%                       targY3 = struct80(s).annotation.object(targIdx(3)).polygon.y;
%                       targX4 = struct80(s).annotation.object(targIdx(4)).polygon.x; %target polygon2
%                       targY4 = struct80(s).annotation.object(targIdx(4)).polygon.y;
%                       
%                       p1 = polyshape(targX1,targY1); p2 = polyshape(targX2,targY2); p3 = polyshape(targX3,targY3); p4 = polyshape(targX4,targY4);
%                       polyout = union(p1,p2); polyout2 = union(p3,p4); polyout3 = union(polyout,polyout2) %create single polygon
%                       targX = polyout3.Vertices(:,1); targX(isnan(targX)) = [];
%                       targY = polyout3.Vertices(:,2); targY(isnan(targY)) = [];   
%                    end

    targX = round(struct80EditsOneWord(trial).annotation.object(targIdx).polygon.x./scaled); %target polygon
    targY = round(struct80EditsOneWord(trial).annotation.object(targIdx).polygon.y./scaled-1);

    figure
    imagesc(myImage)
    hold on
    drawpolygon('Position',[targX,targY]);
            
    struct80EditsOneWord(trial).annotation.targetCoords.x = targX;
    struct80EditsOneWord(trial).annotation.targetCoords.y = targY;
    
 end
