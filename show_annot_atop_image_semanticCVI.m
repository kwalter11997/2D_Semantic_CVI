%% Library Check (show annotation on top of image)

FINALIMAGES = 'C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\images';
FINALANNOTATIONS = 'C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\annotations';
cd(FINALANNOTATIONS)

D = dir; 
D = D(~ismember({D.name}, {'.', '..'})); %first elements are '.' and '..' used for navigation - remove these
fileNames = {D.name}; %get all the file names

for n = 1:length(fileNames)
    cd(FINALANNOTATIONS)
    file = char(fileNames(n));
    annotation = LMread(file); 
    figure();
    imshow(erase([FINALIMAGES,'\',file,'.jpg'],'.xml'))
    f = LMplot(annotation);
    [h,class] = LMplot(annotation)
    title(file);
    
    cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\imageMasks')
    saveas(gcf,sprintf('%s.png',erase(file,'.xml')))
    close all
end

figure()
LMobjectmask(annotation,'C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\images','minar');
LMplot(annotation);

%% manual cleanup

cd('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI')
load('original80_withSemanticMap_final2.mat')

%remove old semanticIm
for s = 1:80
   struct80(s).annotation  = rmfield(struct80(s).annotation, 'semanticIm')
end

cd('E:\2D_Semantic_CVI\images')

imagesc(imread(struct80EditsOneWord(12).annotation.filename))
hold on
LMplot(struct80EditsOneWord(12).annotation);

plot([947;154;150;952],[947;154;150;952],'r','LineWidth',5)