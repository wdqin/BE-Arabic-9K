import cv2
import csv 
import torch
import utils
from PIL import Image
import torchvision.transforms as transforms
import torchvision
from param import args
import datetime
import xml.etree.ElementTree as ET
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor


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

def create_testing_input(img_path,device):
    transform = transforms.Compose([transforms.ToTensor(),])
    img = Image.open(img_path).convert("RGB")
    image_tensor = transform(img)
    image_tensor_gpu = image_tensor.to(device)
    return image_tensor_gpu

def load_model(model_path):
    model = torchvision.models.detection.fasterrcnn_resnet50_fpn(pretrained=True)
    num_classes = 3
    in_features = model.roi_heads.box_predictor.cls_score.in_features
    model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)
    new_aspect_ratios = (0.5, 1.0, 2.0)
    new_aspect_ratios = (new_aspect_ratios,) * len(model.rpn.anchor_generator.sizes)
    model.rpn.anchor_generator.aspect_ratios = new_aspect_ratios
    model.load_state_dict(torch.load(model_path))
    print("FFRA model load complete.")

    return model

def draw_boxes_in_image(image,boxes_text,boxes_picture,out_path):
    def draw_box(image,boxes,color):
        for box in boxes:
            xmin = int(box.x_left)
            xmax = int(box.x_right)
            ymin = int(box.y_top) 
            ymax = int(box.y_bottom)
            start_point = (xmin,ymin)
            end_point = (xmax,ymax)
            thickness = 9
            image_to_draw = cv2.rectangle(image, start_point, end_point, color, thickness) 

    draw_boxes(image,oxes_text,text_color)
    draw_boxes(image,boxes_picture,picture_color)
    cv2.imwrite(out_path,image_to_draw)
    return image_to_draw

def merging_intersected_boxes(boxes,i_r_threshold): # a brute-force way to merge overlapped bounding boxes until there's none
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
                    logical_class = int(box_A.logical_class)
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
            image = cv2.rectangle(image, start_point, end_point, color, thickness) 
        return image
    text_color = (255,0,0)
    picture_color = (0,255,0)

    image = draw_boxes(image,boxes_text,text_color)
    image = draw_boxes(image,boxes_picture,picture_color)
    cv2.imwrite(out_path,image)
    
    return image

def write_xml(image,image_name,boxes_text,boxes_picture,out_file_name):
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
    Page.set('imageFilename',image_name)
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

def get_predictions(output):
    boxes_text_list = []
    boxes_picture_list = []
    for i in range(len(output["boxes"])):
        if(output["scores"][i]>args.region_acceptance_score):
            x1 = int(output["boxes"][i][0])
            y1 = int(output["boxes"][i][1])
            x2 = int(output["boxes"][i][2])
            y2 = int(output["boxes"][i][3])
            box = BoundingBox(output["labels"][i],x1,x2,y1,y2)
            if(output["labels"][i]==1):
                boxes_text_list.append(box)
            elif(output["labels"][i]==2):
                boxes_picture_list.append(box)        
    return boxes_text_list, boxes_picture_list

def get_result(model,device):
    print("generating results based on the parameter inputs from your script...")
    splits = [args.evaluation_set]
    with open(args.data_info_path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        testing_batch = []
        imgs_to_draw_batch = []
        output_jpg_path_batch = []
        output_xml_path_batch = []
        imgs_name_batch = []
        for row in reader:
            if(int(row['split_index'])in splits):
                img = Image.open(args.dataset_dir+"/jpg/"+row['hashed_prefix']+".jpg").convert("RGB")
                img_tensor = torchvision.transforms.ToTensor()(img)
                testing_batch.append(img_tensor.to(device))
                imgs_to_draw_batch.append(cv2.imread(args.dataset_dir+"/jpg/"+row['hashed_prefix']+".jpg"))
                imgs_name_batch.append(row['hashed_prefix']+".jpg")
                output_jpg_path_batch.append(args.visualization_output_directory+"/"+row['hashed_prefix']+".jpg")
                output_xml_path_batch.append(args.xml_output_directory+"/"+row['hashed_prefix']+".xml")
                
                if(len(testing_batch)==args.batch_size):
                    outputs = model(testing_batch)
                    for i,output in enumerate(outputs):
                        boxes_text,boxes_picture = get_predictions(output)
                        boxes_text = merging_intersected_boxes(boxes_text,args.i_r_threshold)
                        boxes_picture = merging_intersected_boxes(boxes_picture,args.i_r_threshold)
                        image_to_draw = draw_boxes_in_image(imgs_to_draw_batch[i],boxes_text,boxes_picture,output_jpg_path_batch[i])
                        write_xml(imgs_to_draw_batch[i],imgs_name_batch[i],boxes_text,boxes_picture,output_xml_path_batch[i])
                    testing_batch = []
                    imgs_to_draw_batch =[]
                    imgs_name_batch = []
                    output_jpg_path_batch = []
                    output_xml_path_batch = []





def main():
    device = torch.device('cuda') if torch.cuda.is_available() else torch.device('cpu')
    model = load_model(args.model_path)
    model.to(device)
    model.eval()
    get_result(model,device)




if __name__ == "__main__":
    main()



