function [semanticIm] = GloVeSemanticCVI(fileNameShort, myImage, queryList, emb, struct80EditsOneWord, a)

FINALIMAGES = 'C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\images';
annotation = struct80EditsOneWord(a).annotation

imSize=size(myImage);
nObjects=length(annotation.object);

%nObjects = struct.(['F_' folderName]).(['File_' fileName]).nObjs; 
myMask=false([imSize(1)  imSize(2) nObjects]); % set up memory for areas of all objects
objSize=zeros(1, nObjects); % list of object sizes

% objName={};
% figure();
% imshow(myImage);
% LineWidth=2;
% hold on
for objNum=1:nObjects
    xLoc=annotation.object(objNum).polygon.x; % extract vertices of labeled object
    yLoc=annotation.object(objNum).polygon.y;
%     xLoc=str2num(char(struct.(['F_' folderName]).(['File_' fileName]).polygons{objNum,1}.pt.x)); % extract vertices of labeled object
%     yLoc=str2num(char(struct.(['F_' folderName]).(['File_' fileName]).polygons{objNum,1}.pt.y));
%     drawpolygon('Position',[xLoc'; yLoc']'); % draw object outline on figure alternative:     plot([xLoc; xLoc(1)],[yLoc; yLoc(1)], 'LineWidth', LineWidth, 'color', [0 0 0]); 
    myMask(:,:,objNum) = roipoly(myImage,xLoc,yLoc); % find logical polygon for this object
    objSize(objNum)=sum(sum(myMask(:,:,objNum))); % size of this object
    %objName(objNum)=struct.(['F_' folderName]).(['File_' fileName]).objects(objNum);
    objName(objNum) = {annotation.object(objNum).name};
end
%hold off

%% Conduct Semantic Salinence analysis for this image's objects

nQueries=length(queryList);
objectSemanticSim=zeros(nQueries,nObjects);

queryList = strrep(queryList, '_', ' '); %get rid of any connecting underscores (replace with space)
queryList = strrep(queryList, '/', ' ');

semanticQueryList = [];
for queryNum=1:nQueries
    queryNum
    queryTerm = queryList(queryNum);
    queryTerm = split(queryTerm, ' '); %split into individual words
    
%     if length(queryTerm) > 1 %if query word is multiple parts
%         for q = 1:length(queryTerm) %go through each word part
%             wq(:,q) = word2vec(emb,queryTerm{q}); %grab vectors for each word part and add to cell matrix w
%         end
%         queryTerm = vec2word(emb,wq(:,1)+wq(:,2)); %combine to find new common word
%     end
%     wv1 = word2vec(emb,queryTerm); %grab vector for this scene label word

    semanticSimList = [];
    semanticSim = [];
    
    for q = 1:length(queryTerm) %go through each word part
        
        wv1 = word2vec(emb,queryTerm(q)); %grab vector for this scene label word
    
        for objNum=1:nObjects % go through objects
            objNum
            objTerm = split(objName{objNum}); %split words that are multiples into seperate words

            if length(objTerm) > 1 %if a word is more than 1 word
                for o = 1:length(objTerm) %go through each word part
                    wo(:,o) = word2vec(emb,objTerm{o}); %grab vectors for each word part and add to cell matrix w
                end
                objTerm = vec2word(emb,sum(wo,2)); %combine to find new common word
            end
            wv2 = word2vec(emb,objTerm); %grab vector for this object word
            semanticSimList(q,objNum) = dot(wv1,wv2)/ (sqrt(dot(wv1,wv1))*sqrt(dot(wv2,wv2))); %find cosine angle between scene label word and object word
        end
    end
    semanticSim = mean(semanticSimList,1); %average the queryterm lists together
    semanticQueryList(queryNum,:) = semanticSim; %throw this vector into a matrix for all query values
end

% figure()
for queryNum=1:nQueries
    %indivSemanticIm=nanmean(objectSemanticSim(queryNum,:))*ones(imSize(1),imSize(2)); % mean value similarity image for object similarities
    indivSemanticIm=zeros(imSize(1),imSize(2)); %create an empty matrix to fill
    
    [~,sizeOrder] = sort(objSize, 'descend'); % start with largest object
    for objNum=1:nObjects % work through objects in size order to minimize occlusions
        currentObject=sizeOrder(objNum); % next largest object
        indivSemanticIm(myMask(:,:,currentObject)==1)=semanticQueryList(queryNum,currentObject); % assign pixels to this similarity
    end

    semanticImList(queryNum) = {indivSemanticIm};
    
%     subplot(2,3,queryNum); % plot each image in sub plot
%     imagesc(indivSemanticIm); % show each image
%     colorbar; % show the scale
%     queryList{queryNum} = replace(queryList{queryNum},'_','\_');
%     title(queryList{queryNum}); % show the similarity item
end

combList = cat(3,semanticImList{:}); %cat makes the cells (which are 2d matricies) into a cube structure, effectively stacking them, then divide across the 3rd dimension (averaging the "stacks")
semanticIm = nanmean(combList,3); %average maps
% semanticIm = combList; %keep maps seperate
%change nans to 0s to avoid errors down the line (nan is essentially 0)
semanticIm(isnan(semanticIm)) = 0;

% subplot(2,3,6)
% imagesc(semanticIm)
% colorbar; % show the scale
% title('Average Semantic Relevance'); % show the similarity item

cd(FINALIMAGES)