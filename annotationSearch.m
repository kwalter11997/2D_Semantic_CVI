%% Find 80 corresponding annotation files for semantic CVI image study

fnames = dir('C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\images')
fnames = {fnames.name};
fnames = fnames(3:end); %remove . and ..

foldernames = dir('E:\SceneProcessing\LabelMe\annotations')
foldernames = {foldernames.name};
foldernames = foldernames(3:end);

for file = 1:length(fnames) %search for each file
    targetFile = append(erase(fnames(file),'.jpg'),'.xml') %target file to be found
    for folder = 1:length(foldernames) %look in each folder
        targetFolder = dir(append('E:\SceneProcessing\LabelMe\annotations\', string(foldernames(folder))));
        folderFiles = {targetFolder.name};
        if any(strcmp(targetFile,folderFiles)) %if the file is in this folder            
            copyfile(append('E:\SceneProcessing\LabelMe\annotations\', string(foldernames(folder)), '\', targetFile), "C:\Users\Kerri\Dropbox\Kerri_Walter\2D_Semantic_CVI\annotations") %copy the annotation file to new folder
            continue %move on to next file
        end
    end
end
    