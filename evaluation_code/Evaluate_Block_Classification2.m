function ClassificationResults = Evaluate_Block_Classification2(I,XMLName,TextRegions,ImgRegions, TextPoly, ImgPoly)
ClassificationResults = [];
GroundTextBlocks = [];
GroundImgBlocks = [];

if length(size(I))==3 %in case of Colored RGB image input
    J = rgb2gray(I);
    I = [];
    I = J;
end

GTTextRegNum = 0; % Total No. of text regions in the GT
GTImgRegNum = 0; % Total No. of non-text regions in the GT

level = graythresh(I);
BatchBW = im2bw(I,level);
BWInv = ~BatchBW;

read_xml=xml2struct(XMLName);                                      % read and save xml into structure
Region_name=read_xml.Children(4).Children;                          % read and save all regions data within the image
Region_counter=1;                                                   % regions counter
while(Region_counter<=size(Region_name,2))                          % Loop on all regions within the current image file
    if(strcmp(Region_name(Region_counter).Name,'TextRegion'))
        GTTextRegNum=GTTextRegNum+1;
        
        p=Region_name(Region_counter).Children;
        zz=p(2).Attributes.Value;                                   % Extracting as strings
        x = strread(zz,'%s','delimiter',' ');
        xx1=cell2mat(x(1));
        yy1 = strread(xx1,'%s','delimiter',',');
        xx2=cell2mat(x(2));
        yy2 = strread(xx2,'%s','delimiter',',');
        xx3=cell2mat(x(3));
        yy3 = strread(xx3,'%s','delimiter',',');
        xx4=cell2mat(x(4));
        yy4 = strread(xx4,'%s','delimiter',',');
        
        a=str2num(cell2mat(yy1(1)));                                % Conversion to numbers
        b=str2num(cell2mat(yy1(2)));
        c=str2num(cell2mat(yy2(1)));
        d=str2num(cell2mat(yy2(2)));
        e=str2num(cell2mat(yy3(1)));
        f=str2num(cell2mat(yy3(2)));
        g=str2num(cell2mat(yy4(1)));
        h=str2num(cell2mat(yy4(2)));
        
        GroundTextBlocks(GTTextRegNum,1:4) = [min([a,c,e,g]) max([a,c,e,g]) min([b,d,f,h]) max([b,d,f,h])];
        
    elseif(strcmp(Region_name(Region_counter).Name,'ImageRegion')) % Non-Text regions
        GTImgRegNum=GTImgRegNum+1;
        
        p=Region_name(Region_counter).Children;
        zz=p(2).Attributes.Value;                                   % Extracting as strings
        x = strread(zz,'%s','delimiter',' ');
        xx1=cell2mat(x(1));
        yy1 = strread(xx1,'%s','delimiter',',');
        xx2=cell2mat(x(2));
        yy2 = strread(xx2,'%s','delimiter',',');
        xx3=cell2mat(x(3));
        yy3 = strread(xx3,'%s','delimiter',',');
        xx4=cell2mat(x(4));
        yy4 = strread(xx4,'%s','delimiter',',');
        
        a=str2num(cell2mat(yy1(1)));                                % Conversion to numbers
        b=str2num(cell2mat(yy1(2)));
        c=str2num(cell2mat(yy2(1)));
        d=str2num(cell2mat(yy2(2)));
        e=str2num(cell2mat(yy3(1)));
        f=str2num(cell2mat(yy3(2)));
        g=str2num(cell2mat(yy4(1)));
        h=str2num(cell2mat(yy4(2)));
        
        GroundImgBlocks(GTImgRegNum,1:4) = [min([a,c,e,g]) max([a,c,e,g]) min([b,d,f,h]) max([b,d,f,h])];
    end
    Region_counter=Region_counter+1;
end

TP = 0; TN = 0;
FP = 0; FN = 0;
% GroundTextBlocks
% GroundImgBlocks
% TextPoly
% ImgPoly
for j5 = 1:TextPoly %Loop on text regions in the "segmented image"
    SegmentedTextBlocks(j5,1:4) = TextRegions{j5,1}.Coords(1:4); %read and save the bounding box information of text region
    
    WhereVector = zeros(1,length(SegmentedTextBlocks(j5,1):SegmentedTextBlocks(j5,2))*length(SegmentedTextBlocks(j5,3):SegmentedTextBlocks(j5,4)));
    xvec = zeros(1,length(SegmentedTextBlocks(j5,1):SegmentedTextBlocks(j5,2))*length(SegmentedTextBlocks(j5,3):SegmentedTextBlocks(j5,4)));
    yvec = zeros(1,length(SegmentedTextBlocks(j5,1):SegmentedTextBlocks(j5,2))*length(SegmentedTextBlocks(j5,3):SegmentedTextBlocks(j5,4)));
    
    cntr = 1; 
	% Fill in the the x-y coordinates of all pixels inside the segmented block
    for xval = SegmentedTextBlocks(j5,1):SegmentedTextBlocks(j5,2)
        xvec(cntr:cntr+length(SegmentedTextBlocks(j5,3):SegmentedTextBlocks(j5,4))-1) = xval;
        yvec(cntr:cntr+length(SegmentedTextBlocks(j5,3):SegmentedTextBlocks(j5,4))-1) = SegmentedTextBlocks(j5,3):1:SegmentedTextBlocks(j5,4);
        cntr = cntr+length(SegmentedTextBlocks(j5,3):SegmentedTextBlocks(j5,4));
    end
    % Loop on GT text blocks, store the bounding box coordinates and check if the pixels of the current segmented block lie inside it, if so set the corresponding PickedGTBlock element to 1, o.w. continue to the next GT block.
    Flag = 0;
    for j6 = 1:GTTextRegNum
        Gxvec = [GroundTextBlocks(j6,1);GroundTextBlocks(j6,2);GroundTextBlocks(j6,2);GroundTextBlocks(j6,1);GroundTextBlocks(j6,1)];
        Gyvec = [GroundTextBlocks(j6,3);GroundTextBlocks(j6,3);GroundTextBlocks(j6,4);GroundTextBlocks(j6,4);GroundTextBlocks(j6,3)];
        IN = inpolygon(xvec',yvec',Gxvec,Gyvec);
        sum(IN)
        if sum(IN)>0
            Flag = 1;
            break;
        end
    end
    if Flag
        TP = TP + 1;
    else
        FP = FP + 1;
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for j5 = 1:ImgPoly %Loop on non-text regions in the "segmented image"
    SegmentedImgBlocks(j5,1:4) = ImgRegions{j5,1}.Coords(1:4); %read and save the bounding box information of text region
    
    WhereVector = zeros(1,length(SegmentedImgBlocks(j5,1):SegmentedImgBlocks(j5,2))*length(SegmentedImgBlocks(j5,3):SegmentedImgBlocks(j5,4)));
    xvec = zeros(1,length(SegmentedImgBlocks(j5,1):SegmentedImgBlocks(j5,2))*length(SegmentedImgBlocks(j5,3):SegmentedImgBlocks(j5,4)));
    yvec = zeros(1,length(SegmentedImgBlocks(j5,1):SegmentedImgBlocks(j5,2))*length(SegmentedImgBlocks(j5,3):SegmentedImgBlocks(j5,4)));
    
    cntr = 1; 
    for xval = SegmentedImgBlocks(j5,1):SegmentedImgBlocks(j5,2)
        xvec(cntr:cntr+length(SegmentedImgBlocks(j5,3):SegmentedImgBlocks(j5,4))-1) = xval;
        yvec(cntr:cntr+length(SegmentedImgBlocks(j5,3):SegmentedImgBlocks(j5,4))-1) = SegmentedImgBlocks(j5,3):1:SegmentedImgBlocks(j5,4);
        cntr = cntr+length(SegmentedImgBlocks(j5,3):SegmentedImgBlocks(j5,4));
    end
    Flag = 0;
    for j6 = 1:GTImgRegNum
        Gxvec = [GroundImgBlocks(j6,1);GroundImgBlocks(j6,2);GroundImgBlocks(j6,2);GroundImgBlocks(j6,1);GroundImgBlocks(j6,1)];
        Gyvec = [GroundImgBlocks(j6,3);GroundImgBlocks(j6,3);GroundImgBlocks(j6,4);GroundImgBlocks(j6,4);GroundImgBlocks(j6,3)];
        IN = inpolygon(xvec',yvec',Gxvec,Gyvec);
        
        if sum(IN)>0
            Flag = 1;
            break;
        end
    end
    if Flag
        TN = TN + 1;
    else
        FN = FN + 1;
    end
end

% TextPr = TP / (TP + FP);
% TextR = TP / (TP + FN);
% TextF1 = 100*2*(TextPr*TextR)/(TextPr+TextR);
% 
% NonTextPr = TN / (TN + FN);
% NonTextR =  TN / (TN + FP);
% NonTextF1 = 100*2*(NonTextPr*NonTextR)/(NonTextPr+NonTextR);
% TextPoly
% ImgPoly
% TN
% FN
% FP
% TP

if(TextPoly == 0)
    Pr = TN / (TN + FN);
    Rec =  TN / (TN + FP);    
    if (sum([TN,FN])==0)||(sum([TN,FP])==0)
        AllF1 = 0;
    else
        AllF1 = 100*2*(Pr*Rec)/(Pr+Rec);
    end
elseif (ImgPoly ==0)
    Pr = TP / (TP + FP);
    Rec =  TP / (TP + FN);
    if (sum([TP,FP])==0)||(sum([TP,FN])==0)
        AllF1 = 0;
    else    
        AllF1 = 100*2*(Pr*Rec)/(Pr+Rec);
    end
else
    Pr1 = TN / (TN + FN);
    Rec1 =  TN / (TN + FP);
    AllF11 = 100*2*(Pr1*Rec1)/(Pr1+Rec1);
    Pr2 = TP / (TP + FP);
    Rec2 =  TP / (TP + FN);
    AllF12 = 100*2*(Pr2*Rec2)/(Pr2+Rec2);
    if ((sum([TN,FN])==0)||(sum([TN,FP])==0)||(sum([TP,FP])==0)||(sum([TP,FN])==0)|| ((Pr1+Rec1)==0)||((Pr2+Rec2)==0))
        AllF1 = 0;
        
    else
        AllF1 = mean([AllF11,AllF12]);
        %AllF1 = AllF11;
        %AllF1 = AllF12;
    end
end
BlockAccuracy = 100*(TN+TP) / (TP + FP + TN + FN);
TextBlockAccuracy = 100*(TP)/(TP+FP)
NonTextBlockAccuracy = 100*(TN)/(TN+FN)

ClassificationResults = [ClassificationResults AllF1 BlockAccuracy];
%ClassificationResults = [ClassificationResults AllF1 TextBlockAccuracy];
%ClassificationResults = [ClassificationResults AllF1 NonTextBlockAccuracy];
