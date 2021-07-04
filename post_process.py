class Point:
    def __init__(self,setX,setY):
        self.x = setX
        self.y = setY
    def printPoint(self):
        print("x: "+str(self.x))
        print("y: "+str(self.y))
class BoundingBox:
    def __init__(self,set_logical_class,set_x_left,set_x_right,set_y_top,set_y_bottom):
        self.logical_class = set_logical_class
        self.x_left = set_x_left
        self.x_right = set_x_right
        self.y_top = set_y_top
        self.y_bottom = set_y_bottom
    def printBox(self):
        print("logical_class: "+str(self.logical_class))
        print("x_left: "+str(self.x_left))
        print("x_right: "+str(self.x_right))
        print("y_top: "+str(self.y_top))
        print("y_bottom: "+str(self.y_bottom))

def read_image(image_path):
    image = cv2.imread(image_path)
    return image

def read_boxes(boxes_path):
    boxes_text_list = []
    boxes_picture_list = []
    with open(boxes_path,newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            box = BoundingBox(int(row['label']),int(row['xmin']),int(row['xmax']),int(row['ymin']),int(row['ymax']))
#             print(row['label'])
            if(int(row['label'])==1): #text
#                 print("text")
                boxes_text_list.append(box)
            elif(int(row['label'])==2): #non-text
#                 print("not text")
                boxes_picture_list.append(box)
    return boxes_text_list,boxes_picture_list

def draw_boxes_in_image(image,boxes_text,boxes_picture,out_path):
    def draw_boxes(image,boxes,color):
        for box in boxes:
            xmin = int(box.x_left)
            xmax = int(box.x_right)
            ymin = int(box.y_top) 
            ymax = int(box.y_bottom)
            start_point = (xmin,ymin)
            end_point = (xmax,ymax)
            thickness = 9
            image_to_draw = cv2.rectangle(image, start_point, end_point, color, thickness) 

    draw_boxes(image,boxes_text,text_color)
    draw_boxes(image,boxes_picture,picture_color)
    cv2.imwrite(out_path,image_to_draw)
    
    return image_to_draw

#computing the overlaid area of two bounding boxes, 
#if the area is large enough to the smaller bounding box, 
#we merge them.
# ----------------------------------------------------------------#
def intersected_area(box_A, box_B):  # returns None if rectangles don't intersect
    dx = min(box_A.x_right, box_B.x_right) - max(box_A.x_left, box_B.x_left) 
    dy = min(box_A.y_bottom, box_B.y_bottom) - max(box_A.y_top, box_B.y_top)
    if (dx>=0) and (dy>=0):
        return dx*dy
    else:
        return 0
def ratio_of_intersection_to_small_box(box_A,box_B):
    area_intersected = intersected_area(box_A,box_B)
    area_A = (box_A.x_right-box_A.x_left)*(box_A.y_bottom-box_A.y_top)
    area_B = (box_B.x_right-box_B.x_left)*(box_B.y_bottom-box_B.y_top)
    
    if(area_A>area_B):
        ratio = area_intersected/area_B
    else:
        ratio = area_intersected/area_A
        
    return ratio

def merging_intersected_boxes(boxes,i_r_threshold):
    i=0
    j=0
    length_of_boxes_list = len(boxes)
    while(i<length_of_boxes_list):
            if(i!=j): #if the two bounding boxes are not the same box
                box_A = boxes[i]
                box_B = boxes[j]
                intersect_ratio = ratio_of_intersection_to_small_box(box_A,box_B)
                if(intersect_ratio>i_r_threshold): # we need to merge the boxes, and start over in case of any missing merge
                    x_left = min(int(box_A.x_left),int(box_B.x_left))
                    x_right = max(int(box_A.x_right),int(box_B.x_right))
                    y_top = min(int(box_A.y_top),int(box_B.y_top))
                    y_bottom = max(int(box_A.y_bottom),int(box_B.y_bottom))
                    logical_class = int(box_A.logicalClass)
                    boxes[i]= BoundingBox(logical_class,x_left,x_right,y_top,y_bottom)
                    del boxes[j]
                    length_of_boxes_list = len(boxes)
                    i=0 
                    j=0
                else: # we don't need to merge the boxes
                    j+=1
#                     print("hit")
                    if(j>=length_of_boxes_list):
                        j=0
                        i+=1
#                         print("hit2")
            else:
                j+=1
                if(j>=length_of_boxes_list):
                    j=0
                    i+=1

    return boxes
# ----------------------------------------------------------------#

# converting the merged result into proper format  (.xml) for evaluation
def write_xml(image,boxes_text,boxes_picture,out_file_name):
    time = datetime.datetime.today()
    PcGts = ET.Element("PcGts")
    PcGts.set('xmlns','http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15')
    PcGts.set('xmlns:xsi','http://www.w3.org/2001/XMLSchema-instance')
    PcGts.set('xsi:schemaLocation','http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15 http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15/pagecontent.xsd')
    Metadata = ET.SubElement(PcGts,"Metadata")
    Creator = ET.SubElement(Metadata,"Creator")
    Created = ET.SubElement(Metadata,"Created").text = str(time.year)+"-"+str(time.month)+"-"+str(time.day)+"T"+str(time.hour)+":"+str(time.minute)+":"+str(time.second)
    LastChange = ET.SubElement(Metadata,"LastChange").text = str(time.year)+"-"+str(time.month)+"-"+str(time.day)+"T"+str(time.hour)+":"+str(time.minute)+":"+str(time.second)
    Page = ET.SubElement(PcGts,"Page")
    Page.set('imageFilename','image'+str(i)+'.jpg')
    height = image.shape[0]
    width = image.shape[1]
    Page.set('imageWidth',str(width))
    Page.set('imageHeight',str(height))
    index_count = 0
    for box in boxes_text:
        index_count+=1
        xl = box.x_left
        if(xl<=0):
            xl+=1
        xr = box.x_right
        yt = box.y_top
        if(yt<=0):
            yt+=1
        yb = box.y_bottom
        TextRegion = ET.SubElement(Page,'TextRegion')
        TextRegion.set('id',"r"+str(index_count))
        Coords = ET.SubElement(TextRegion,'Coords')
        Coords.set('points',str(xl)+","+str(yt)+" "+str(xl)+","+str(yb)+" "+str(xr)+","+str(yb)+" "+str(xr)+","+str(yt))

    for box in boxes_picture:
        index_count+=1
        xl = box.x_left
        if(xl<=0):
            xl+=1
        xr = box.x_right
        yt = box.y_top
        if(yt<=0):
            yt+=1
        yb = box.y_bottom
        ImageRegion = ET.SubElement(Page,'ImageRegion')
        ImageRegion.set('id',"r"+str(index_count))
        Coords = ET.SubElement(ImageRegion,'Coords')
        Coords.set('points',str(xl)+","+str(yt)+" "+str(xl)+","+str(yb)+" "+str(xr)+","+str(yb)+" "+str(xr)+","+str(yt))

    tree = ET.ElementTree(PcGts)
    tree.write(out_file_name,encoding='UTF-8', xml_declaration=True)

