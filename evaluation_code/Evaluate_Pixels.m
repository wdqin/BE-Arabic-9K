function PixelResults = Evaluate_Pixels(I,XMLName,TextRegions,ImgRegions, TextPoly, ImgPoly)
PixelResults = [];

[rows, cols] = size(I);
Delta = zeros(rows,cols); % element = 1 if the ground truth pixel label at position x matches the predicted pixel label, o.w. element = 0;
FG = zeros(rows,cols); % = 1 if x is a foreground pixel, and zero otherwise.

if length(size(I))==3 %in case of Colored RGB image input
    J = rgb2gray(I);
    I = [];
    I = J;
end
% size(I)
SegPixels = zeros(rows,cols);
GTPixels = zeros(rows,cols);

GTTextRegNum = 0; % Total No. of text regions in the GT
GTImgRegNum = 0; % Total No. of non-text regions in the GT

% Binarizing and inverting the input image
level = graythresh(I);
BatchBW = im2bw(I,level);
BWInv = ~BatchBW;
% size(BWInv)
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
        
        xmin = min([a,c,e,g]);
        xmax = max([a,c,e,g]);
        ymin = min([b,d,f,h]);
        ymax = max([b,d,f,h]);
        xmin = max(1,xmin); ymin = max(1,ymin);
        
        GroundTextBlocks(GTTextRegNum,1:4) = [xmin xmax ymin ymax];

        GTPixels(xmin:xmax,ymin:ymax) = 1;
        for x1 = xmin:xmax
            for x2 = ymin:ymax
                if(BWInv(x2,x1)==1)
                   FG(x2,x1) = 1; 
                end
            end
        end
        
    
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
        
        xmin = min([a,c,e,g]);
        xmax = max([a,c,e,g]);
        ymin = min([b,d,f,h]);
        ymax = max([b,d,f,h]);
        xmin = max(1,xmin); ymin = max(1,ymin);
        
        GroundImgBlocks(GTImgRegNum,1:4) = [xmin xmax ymin ymax];
        
        GTPixels(xmin:xmax,ymin:ymax) = 2;
        for x1 = xmin:xmax
            for x2 = ymin:ymax
                if(BWInv(x2,x1)==1)
                   FG(x2,x1) = 1; 
                end
            end
        end
        
    end
    Region_counter=Region_counter+1;
end

for j5 = 1:TextPoly %Loop on text regions in the "segmented image"
    SegmentedTextBlocks(j5,1:4) = TextRegions{j5,1}.Coords(1:4); %read and save the bounding box information of text region
    SegPixels(SegmentedTextBlocks(j5,1):SegmentedTextBlocks(j5,2),SegmentedTextBlocks(j5,3):SegmentedTextBlocks(j5,4)) = 1;
end

for j5 = 1:ImgPoly %Loop on non-text regions in the "segmented image"
    SegmentedImgBlocks(j5,1:4) = ImgRegions{j5,1}.Coords(1:4); %read and save the bounding box information of text region
    SegPixels(SegmentedImgBlocks(j5,1):SegmentedImgBlocks(j5,2),SegmentedImgBlocks(j5,3):SegmentedImgBlocks(j5,4)) = 2;
end

for x1 = 1:rows
   for x2 = 1:cols
      if SegPixels(x1,x2)== GTPixels(x1,x2)
          Delta(x1,x2) = 1;
      end
   end
end

TPA = 100* sum(sum(Delta))/(rows*cols);
FgPA = 100* sum(sum(FG .* Delta))/sum(sum(FG));
PixelResults = [PixelResults TPA FgPA];