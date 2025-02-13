rep = readtable('replacelabel.csv'); 

for f = 1:80
    f
    fileName = fileNames{f};

    [annotation]=LMread(fileName,FINALANNOTATIONS);
    objList = {annotation.object.name}'
    
    %remove/replace annotations based on Xin's list
    for r = 1:length(rep.old)
        repInd = find(strcmp(rep.old(r), objList))
        if ~isempty(repInd)
            if strcmp(rep.new(repInd),'')
               annotation.object.name 
                objList(repInd) = rep.new(repInd)
        end
    end
    
    %remove any rando empty labels
    empIdx = cellfun(@isnumeric,objList)
    objList(empIdx) = [];
    
    annotation.object.name = objList
    
    objCounts(f) = length(annotation.object)
end

find(objCounts==1)

fileNames{23}
fileNames{32}