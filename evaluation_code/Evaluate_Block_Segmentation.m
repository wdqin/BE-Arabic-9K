function SegmentationResult = Evaluate_Block_Segmentation(I,XMLName,TextRegions, ImgRegions, TextPoly, ImgPoly)
% This function computes block based segmentation and classification results for a given test image

% Common Errors: over-segmentation (OSE), under-segmentation (USE), missed (MSE), false alarm (FA). AND correct segmentation (CS). The errors represent counts of each corresponding type.

% Assumption 1: "Overlapping" means that at least 1 vertex of the block in "segmented image" is contained "inside" the corresponding BB coordinates of the block in "ground truthed image". Perfect overlap: if 3 or 4 vertices are inbound or overlapping area of segmented block with GT >=90% its own area. Boxes covering the entire page (contain border noise) will not be considered as overlapping as the 4 vertices are outside all ground truth blocks.

% Function inputs:
% ================
% 1. Image file  --> I
% 2. Ground truth file (XML file name) --> XMLName
% 3. Text Segmentation result (ECDP text regions number 'TextPoly' and coordinates 'TextRegions')
% 4. Non-Text Segmentation result (ECDP image region number 'ImgPoly' and coordinates 'ImgRegions')

% Function outputs:
% =================
% 1. Region/block Segmentation results:
% 	- AvgBPR (correctly segmented black pixels)
% 	- Total block oversegmentation errors (Text and Non-text) OSE+OSE2
% 	- Total block undersegmentation errors (Text and Non-text) USE+USE2
% 	- Total block missegmentation errors (Text and Non-text) MSE+MSE2
% 	- Total block false alarm errors (Text and Non-text) FA+FA2
% 	- Total block correct segmentations (Text and Non-text) CS+CS2
% 	- Total Rho measure (OSE+OSE2+USE+USE2+MSE+MSE2)/(Total no. of "groundtruth" zones)

% Method:
% =======
% Step 1: Initializing the output structures
SegmentationResult = [];

% Step 2: read and save all the bounding box information of text and non-text regions of the input image ground truth file (number of regions and the four vertices)
GroundTextBlocks = [];
GroundImgBlocks = [];

if length(size(I))==3 %in case of Colored RGB image input
    J = rgb2gray(I);
    I = [];
    I = J;
end

% Step 3: For all the ground truth text and non-text regions, convert to B&W and compute the total number of contained ground truth 'black/foreground' pixels --> GTBPixels
GTTextRegNum = 0; % Total No. of text regions in the GT
GTImgRegNum = 0; % Total No. of non-text regions in the GT
GTBPixels = 0; % Total No. of black/foreground pixels inside all regions of the GT

% Binarizing and inverting the input image
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
        
        ROIText2 = [];
        ROIText2 = imcrop(BWInv, [GroundTextBlocks(GTTextRegNum,1), GroundTextBlocks(GTTextRegNum,3), GroundTextBlocks(GTTextRegNum,2), GroundTextBlocks(GTTextRegNum,4)]);
        GTBPixels = GTBPixels+ sum(sum(ROIText2));
        
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
        
        ROIImg2 = [];
        ROIImg2 = imcrop(BWInv, [GroundImgBlocks(GTImgRegNum,1), GroundImgBlocks(GTImgRegNum,3), GroundImgBlocks(GTImgRegNum,2), GroundImgBlocks(GTImgRegNum,4)]);
        GTBPixels = GTBPixels+ sum(sum(ROIImg2));
        
    end
    Region_counter=Region_counter+1;
end

% disp('GT text blocks')
% GroundTextBlocks
% disp('GT image blocks')
% GroundImgBlocks

%%%%%%%%%%%%%%%%% Segmentation Evaluation
% Step 4: Initiate all error types for text OSE, USE, MSE, FA and correct segmentation CS to zero.
% Initiate all error types for non-text OSE2, USE2, MSE2, FA2 and correct segmentation CS2 to zero.
OSE = 0; USE = 0; MSE = 0; FA = 0; CS = 0;
OSE2 = 0; USE2 = 0; MSE2 = 0; FA2 = 0; CS2 = 0;

BPG = 0; % Count of black/foreground pixels in the current GT region
BPS = 0; % Count of black/foreground pixels in the current segmented region
% SBPixels = 0; % Total No. of black/foreground pixels inside all regions of the segmented image
% BPRate = 0;

% Define an array of 'Picked' regions with length = No. of Segmented regions) and initiate all to zero (element = 1 if the region has match in the ground truth image, o.w. element = 0)
PickedSegBlock = zeros(1,TextPoly+ImgPoly);

for j5 = 1:TextPoly %Loop on text regions in the "segmented image"
    SegmentedTextBlocks(j5,1:4) = TextRegions{j5,1}.Coords(1:4); %read and save the bounding box information of text region
end
for j5 = 1:ImgPoly %Loop on non-text regions in the "segmented image"
    SegmentedImgBlocks(j5,1:4) = ImgRegions{j5,1}.Coords(1:4); %read and save the bounding box information of text region
end

% Step 5: Loop on text regions in the "ground truth"
%	For "every" block:
%	1. Compute the total no. of black pixels in the "segented image" block --> BPG
%	2. Make 2 vectors X and Y containing the (x,y) coordinates of  all pixels within the ground truth region
%	3. Loop on text regions in the segmented result:
%		3.a Find out the pixels of the current ground truth block lying inside which segmented regions dimensions.
%		3.b check the number of unique segmented regions that encounters the current ground truth block pixels (Modify and mark each of them as 'Picked')
%		3.c if the no. of unique segmented blocks >1 --> USE = USE++ (1 GT block is merged)
%		3.d elseif the no. of unique GT blocks =1, binarize both the 'segmented' and 'ground truth' regions and check the overlapping area, if >=0.95 --> CS = CS++, else OSE = OSE++
%		3.e else (no. of unique Segmented blocks = 0) --> MSE = MSE++
% Step 6: MSE = No. of zeros in 'Picked' array
% Step 7: Repeat steps 5-7 for non-text regions
% Step 8: Average black pixel rate AvgBPR (correctly segmented black pixels) = 100*SBPixels/GTBPixels

for j5 = 1:GTTextRegNum %Loop on text regions in the "ground truth"
    WhereVector = []; xvec = []; yvec = [];
    
    % Initiate to zero Where vector (assigns GT block ID to each pixel), and xvec&yvec storing the x-y coordinates of each pixel inside the segmented block
    WhereVector = zeros(1,length(GroundTextBlocks(j5,1):1:GroundTextBlocks(j5,2))*length(GroundTextBlocks(j5,3):1:GroundTextBlocks(j5,4)));
    xvec = zeros(1,length(GroundTextBlocks(j5,1):1:GroundTextBlocks(j5,2))*length(GroundTextBlocks(j5,3):1:GroundTextBlocks(j5,4)));
    yvec = zeros(1,length(GroundTextBlocks(j5,1):1:GroundTextBlocks(j5,2))*length(GroundTextBlocks(j5,3):1:GroundTextBlocks(j5,4)));
    %     length(xvec)
    
    cntr = 1;
    % Fill in the the x-y coordinates of all pixels inside the GT block
    for yval = GroundTextBlocks(j5,3):GroundTextBlocks(j5,4)
        xvec(cntr:cntr+length(GroundTextBlocks(j5,1):GroundTextBlocks(j5,2))-1) = GroundTextBlocks(j5,1):1:GroundTextBlocks(j5,2);
        yvec(cntr:cntr+length(GroundTextBlocks(j5,1):GroundTextBlocks(j5,2))-1) = yval;
        cntr = cntr+length(GroundTextBlocks(j5,1):GroundTextBlocks(j5,2));
    end
    %     length(find(xvec==0))
    
    % Loop on segmented text blocks, store the bounding box coordinates and check if the pixels of the current segmented block lie inside it, if so set the corresponding PickedSegBlock element to 1, o.w. continue to the next GT block.
    for j6 = 1:TextPoly
        Sxvec = [SegmentedTextBlocks(j6,1);SegmentedTextBlocks(j6,2);SegmentedTextBlocks(j6,2);SegmentedTextBlocks(j6,1);SegmentedTextBlocks(j6,1)];
        Syvec = [SegmentedTextBlocks(j6,3);SegmentedTextBlocks(j6,3);SegmentedTextBlocks(j6,4);SegmentedTextBlocks(j6,4);SegmentedTextBlocks(j6,3)];
        IN = inpolygon(xvec',yvec',Sxvec,Syvec);
        
        if sum(IN)>0
            WhereVector(IN>0) = j6;
            PickedSegBlock(j6) = 1;
        end
    end
    
    % Count how many unique GT blocks contain the segmented pixels, if more than 1 ==> undersegmentation error, else if 1 ==> correct segmentation on condition of 90% overlap, else ==> over-segmentation error. If no GT block match then the segmented block is FA.
    %     j5
    ChosenSeg = unique(WhereVector);
    All = find((ChosenSeg>0)&(ChosenSeg<=TextPoly));
    if length(All)>1
        Portions = zeros(1,length(All));
        ROIText2 = [];
        ROIText2 = imcrop(BWInv, [GroundTextBlocks(j5,1), GroundTextBlocks(j5,3), GroundTextBlocks(j5,2), GroundTextBlocks(j5,4)]);
        BPG = sum(sum(ROIText2));
        
        for x = 1:length(All)
            ROIText2 = [];
            ROIText2 = imcrop(BWInv, [SegmentedTextBlocks(ChosenSeg(All(x)),1), SegmentedTextBlocks(ChosenSeg(All(x)),3), SegmentedTextBlocks(ChosenSeg(All(x)),2), SegmentedTextBlocks(ChosenSeg(All(x)),4)]);
            BPS = sum(sum(ROIText2));
            Minx = max(GroundTextBlocks(j5,1),SegmentedTextBlocks(ChosenSeg(All(x)),1));
            Maxx = min(GroundTextBlocks(j5,2),SegmentedTextBlocks(ChosenSeg(All(x)),2));
            Miny = max(GroundTextBlocks(j5,3),SegmentedTextBlocks(ChosenSeg(All(x)),3));
            Maxy = min(GroundTextBlocks(j5,4),SegmentedTextBlocks(ChosenSeg(All(x)),4));
            Intersection = sum(sum(imcrop(BWInv,[Minx,Miny,Maxx,Maxy])));
            GTArea = (GroundTextBlocks(j5,2)-GroundTextBlocks(j5,1))*(GroundTextBlocks(j5,4)-GroundTextBlocks(j5,3));
            SegArea = (SegmentedTextBlocks(ChosenSeg(All(1)),2)-SegmentedTextBlocks(ChosenSeg(All(1)),1))*(SegmentedTextBlocks(ChosenSeg(All(1)),4)-SegmentedTextBlocks(ChosenSeg(All(1)),3));
            
            Portions(x) = ((Maxx-Minx)*(Maxy-Miny))/GTArea;
        end
        %         Portions
        Perc = find(Portions>0.7);
        
        if length(Perc) == 1
            CS = CS + 1;
        else
            OSE = OSE+ 1;% max(0,length(Portions));
        end
        
    elseif length(All)==1
        ROIText2 = [];
        ROIText2 = imcrop(BWInv, [GroundTextBlocks(j5,1), GroundTextBlocks(j5,3), GroundTextBlocks(j5,2), GroundTextBlocks(j5,4)]);
        BPG = sum(sum(ROIText2));
        
        
        ROIText2 = [];
        ROIText2 = imcrop(BWInv, [SegmentedTextBlocks(ChosenSeg(All(1)),1), SegmentedTextBlocks(ChosenSeg(All(1)),3), SegmentedTextBlocks(ChosenSeg(All(1)),2), SegmentedTextBlocks(ChosenSeg(All(1)),4)]);
        BPS = sum(sum(ROIText2));
        Minx = max(GroundTextBlocks(j5,1),SegmentedTextBlocks(ChosenSeg(All(1)),1));
        Maxx = min(GroundTextBlocks(j5,2),SegmentedTextBlocks(ChosenSeg(All(1)),2));
        Miny = max(GroundTextBlocks(j5,3),SegmentedTextBlocks(ChosenSeg(All(1)),3));
        Maxy = min(GroundTextBlocks(j5,4),SegmentedTextBlocks(ChosenSeg(All(1)),4));
        Intersection = sum(sum(imcrop(BWInv,[Minx,Miny,Maxx,Maxy])));
        GTArea = (GroundTextBlocks(j5,2)-GroundTextBlocks(j5,1))*(GroundTextBlocks(j5,4)-GroundTextBlocks(j5,3));
        SegArea = (SegmentedTextBlocks(ChosenSeg(All(1)),2)-SegmentedTextBlocks(ChosenSeg(All(1)),1))*(SegmentedTextBlocks(ChosenSeg(All(1)),4)-SegmentedTextBlocks(ChosenSeg(All(1)),3));
        LeftArea = SegArea-GTArea;
        
        if (GTArea/SegArea>=0.95)
            CS = CS + 1;
        elseif (GTArea/SegArea<=0.9)&& (round(BPS/BPG)>=1)&&((LeftArea/SegArea)>0.2)
            USE = USE+1;
        end
        %             round(BPG/BPS)
        %             round(BPS/BPG)
        
    else % No Segmented block chosen
        MSE  = MSE + 1;
    end
    
end


%%%%%
for j5 = 1:GTImgRegNum %Loop on text regions in the "segmented image"
    WhereVector = []; xvec = []; yvec = [];
    
    % Initiate to zero Where vector (assigns GT block ID to each pixel), and xvec&yvec storing the x-y coordinates of each pixel inside the segmented block
    WhereVector = zeros(1,length(GroundImgBlocks(j5,1):1:GroundImgBlocks(j5,2))*length(GroundImgBlocks(j5,3):1:GroundImgBlocks(j5,4)));
    xvec = zeros(1,length(GroundImgBlocks(j5,1):1:GroundImgBlocks(j5,2))*length(GroundImgBlocks(j5,3):1:GroundImgBlocks(j5,4)));
    yvec = zeros(1,length(GroundImgBlocks(j5,1):1:GroundImgBlocks(j5,2))*length(GroundImgBlocks(j5,3):1:GroundImgBlocks(j5,4)));
    %     length(xvec)
    
    cntr = 1;
    % Fill in the the x-y coordinates of all pixels inside the segmented block
    for yval = GroundImgBlocks(j5,3):GroundImgBlocks(j5,4)
        xvec(cntr:cntr+length(GroundImgBlocks(j5,1):GroundImgBlocks(j5,2))-1) = GroundImgBlocks(j5,1):1:GroundImgBlocks(j5,2);
        yvec(cntr:cntr+length(GroundImgBlocks(j5,1):GroundImgBlocks(j5,2))-1) = yval;
        cntr = cntr+length(GroundImgBlocks(j5,1):GroundImgBlocks(j5,2));
    end
    
    %     length(find(xvec==0))
    
    % Loop on segmented text blocks, store the bounding box coordinates and check if the pixels of the current segmented block lie inside it, if so set the corresponding PickedSegBlock element to 1, o.w. continue to the next GT block.
    for j6 = 1:ImgPoly
        Sxvec = [SegmentedImgBlocks(j6,1);SegmentedImgBlocks(j6,2);SegmentedImgBlocks(j6,2);SegmentedImgBlocks(j6,1);SegmentedImgBlocks(j6,1)];
        Syvec = [SegmentedImgBlocks(j6,3);SegmentedImgBlocks(j6,3);SegmentedImgBlocks(j6,4);SegmentedImgBlocks(j6,4);SegmentedImgBlocks(j6,3)];
        IN = inpolygon(xvec',yvec',Sxvec,Syvec);
        
        if sum(IN)>0
            WhereVector(IN>0) = TextPoly+j6;
            PickedSegBlock(TextPoly+j6) = 1;
        end
    end
    % Count how many unique GT blocks contain the segmented pixels, if more than 1 ==> undersegmentation error, else if 1 ==> correct segmentation on condition of 90% overlap, else ==> over-segmentation error. If no GT block match then the segmented block is FA.
    %     disp('Image regions')
    %     j5
    ChosenSeg = unique(WhereVector);
    All = find((ChosenSeg>0)&(ChosenSeg>TextPoly));
    if length(All)>1
        Portions = zeros(1,length(All));
        ROIimg2 = [];
        ROIimg2 = imcrop(BWInv, [GroundImgBlocks(j5,1), GroundImgBlocks(j5,3), GroundImgBlocks(j5,2), GroundImgBlocks(j5,4)]);
        BPG = sum(sum(ROIimg2));
        
        for x = 1:length(All)
            ROIimg2 = [];
            ROIimg2 = imcrop(BWInv, [SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,1), SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,3), SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,2), SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,4)]);
            BPS = sum(sum(ROIimg2));
            
            Minx = max(GroundImgBlocks(j5,1),SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,1));
            Maxx = min(GroundImgBlocks(j5,2),SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,2));
            Miny = max(GroundImgBlocks(j5,3),SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,3));
            Maxy = min(GroundImgBlocks(j5,4),SegmentedImgBlocks(ChosenSeg(All(x))-TextPoly,4));
            Intersection = sum(sum(imcrop(BWInv,[Minx,Miny,Maxx,Maxy])));
            GTArea = (GroundImgBlocks(j5,2)-GroundImgBlocks(j5,1))*(GroundImgBlocks(j5,4)-GroundImgBlocks(j5,3));
            SegArea = (SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,2)-SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,1))*(SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,4)-SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,3));
            
            Portions(x) = ((Maxx-Minx)*(Maxy-Miny))/GTArea;
        end
        
        %         Portions
        Perc = find(Portions>0.7);
        
        if length(Perc) == 1
            CS2 = CS2 + 1;
        else
            OSE2 = OSE2+ 1;% max(0,length(Portions));
        end
        
    elseif length(All)==1
        ROIimg2 = [];
        ROIimg2 = imcrop(BWInv, [GroundImgBlocks(j5,1), GroundImgBlocks(j5,3), GroundImgBlocks(j5,2), GroundImgBlocks(j5,4)]);
        BPG = sum(sum(ROIimg2));
        
        ROIText2 = [];
        ROIText2 = imcrop(BWInv, [SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,1), SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,3), SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,2), SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,4)]);
        BPS = sum(sum(ROIText2));
        Minx = max(GroundImgBlocks(j5,1),SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,1));
        Maxx = min(GroundImgBlocks(j5,2),SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,2));
        Miny = max(GroundImgBlocks(j5,3),SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,3));
        Maxy = min(GroundImgBlocks(j5,4),SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,4));
        Intersection = sum(sum(imcrop(BWInv,[Minx,Miny,Maxx,Maxy])));
        GTArea = (GroundImgBlocks(j5,2)-GroundImgBlocks(j5,1))*(GroundImgBlocks(j5,4)-GroundImgBlocks(j5,3));
        SegArea = (SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,2)-SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,1))*(SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,4)-SegmentedImgBlocks(ChosenSeg(All(1))-TextPoly,3));
        LeftArea = SegArea-GTArea;
        
        if (GTArea/SegArea>=0.95)
            CS2 = CS2 + 1;
        elseif (GTArea/SegArea<=0.9)&& (round(BPS/BPG)>=1)&&((LeftArea/SegArea)>0.2)
            USE2 = USE2+1;
        end
        
    else % No segmented block chosen
        MSE2  = MSE2 + 1;
    end
    
end
FA = length(find(PickedSegBlock(1:TextPoly)==0));
FA2 = length(find(PickedSegBlock(TextPoly+1:end)==0));

% Return output stucture
SegmentationResult = [SegmentationResult OSE+OSE2 USE+USE2 MSE+MSE2 FA+FA2 CS+CS2 (OSE+OSE2+USE+USE2+MSE+MSE2)/(GTTextRegNum+GTImgRegNum)];
%SegmentationResult = [SegmentationResult OSE USE MSE FA CS (OSE+USE+MSE)/(GTTextRegNum)];
%if (GTImgRegNum==0)
%    rho = 0;
%else
%    rho = (OSE2+USE2+MSE2)/(GTImgRegNum);
%end
%SegmentationResult = [SegmentationResult OSE2 USE2 MSE2 FA2 CS2 rho];
