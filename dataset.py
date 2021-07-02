# modified by Wenda Qin 7/1/2021

import xml.etree.ElementTree as ET
import torch
import pickle
import os
import torchvision.transforms as transforms
import torchvision
import transforms as T
import csv
from param import args
from PIL import Image


class point:
    def __init__(self,set_x,set_y):
        self.x = set_x
        self.y = set_y
    def print_point(self):
        print("x: "+str(self.x))
        print("y: "+str(self.y))
class boundingbox:
    def __init__(self,set_logical_class,set_x_left,set_x_right,set_y_top,set_y_bottom):
        self.logical_class = set_logical_class
        self.x_left = set_x_left
        self.x_right = set_x_right
        self.y_top = set_y_top
        self.y_bottom = set_y_bottom
    def print_box(self):
        print("logicalClass: "+str(self.logical_class))
        print("x_left: "+str(self.x_left))
        print("x_right: "+str(self.x_right))
        print("y_top: "+str(self.y_top))
        print("y_bottom: "+str(self.y_bottom))

def get_coordinates(region):
    coords = region.find("{http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15}Coords")
    coords_all = coords.attrib['points'].split(' ') #split points by " "
    x_left = None
    x_right = None
    y_top = None
    y_bottom = None
    for point_str in coords_all:
        xys = point_str.split(',')
        set_x = int(xys[0])
        set_y = int(xys[1])
        pt = point(set_x,set_y)
        if(x_left is None):
            x_left = pt.x
        else:
            if x_left > pt.x:
                x_left = pt.x
                
        if(x_right is None):
            x_right = pt.x
        else:
            if x_right<pt.x:
                x_right = pt.x
                
        if(y_top is None):
            y_top = pt.y
        else:
            if y_top>pt.y:
                y_top = pt.y
                
        if(y_bottom is None):
            y_bottom = pt.y
        else:
            if y_bottom<pt.y:
                y_bottom = pt.y
    return x_left,x_right,y_top,y_bottom

def read_boxes_from_ECDP_XML_file(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    page = root.find('{http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15}Page')
    res = []
    for region in page.getchildren():
        if("TextRegion" in region.tag):
            x_left,x_right,y_top,y_bottom = get_coordinates(region)
            bbx = boundingbox("Text",x_left,x_right,y_top,y_bottom)
            res.append(bbx)
        elif ("ImageRegion" in region.tag):
            x_left,x_right,y_top,y_bottom = get_coordinates(region)
            bbx = boundingbox("Image",x_left,x_right,y_top,y_bottom)
            res.append(bbx)
    return res

def create_dictinary(file_name):
    boxes_read = read_boxes_from_ECDP_XML_file(file_name)
    #boxes (FloatTensor[N, 4]): the ground-truth boxes in [x1, y1, x2, y2]
    box_list = []
    label_list = []
    for box in boxes_read:
        single_box = torch.FloatTensor([box.x_left,box.y_top,box.x_right,box.y_bottom])
        box_list.append(single_box)
        if(box.logical_class == "Text"):
            label_list.append(torch.LongTensor([1]))
        else:
            label_list.append(torch.LongTensor([2]))  
    box_tensor = torch.stack(box_list)
    label_tensor = torch.stack(label_list)
    label_tensor = label_tensor.squeeze(1)
    dictionary = {
        "boxes" : box_tensor,
        "labels" : label_tensor
    }
    return dictionary
def get_transform_1(train):
    transforms_list = []
    transforms_list.append(transforms.RandomApply(torch.nn.ModuleList([transforms.GaussianBlur(3)]), p=0.5))
    transforms_list.append(transforms.RandomApply(torch.nn.ModuleList([transforms.ColorJitter(brightness = 0.1)]), p=0.5))
    transforms_list.append(transforms.RandomApply(torch.nn.ModuleList([transforms.ColorJitter(contrast = 0.5)]), p=0.5))

    return transforms.Compose(transforms_list)

def get_transform_2(train):
    transforms = []
    # converts the image, a PIL image, into a PyTorch Tensor
    transforms.append(T.ToTensor())
    if train:
        transforms.append(T.RandomHorizontalFlip(0.5))
    return T.Compose(transforms)

class training_detection_dataset(torch.utils.data.Dataset):
    def __init__(self, evaluation_set, train = False):
        self.evaluation_set = evaluation_set
        self.train = train
        self.transforms_1 = get_transform_1(self.train)
        self.transforms_2 = get_transform_2(self.train)

        all_splits = [0,1,2,3,4,5]
        if(evaluation_set == 0):
            all_splits.pop(0)
        else:
            all_splits.pop(evaluation_set) #remove target testing set x
            all_splits.pop(0) #remove set 0 
        training_splits = all_splits

        self.imgs = []
        self.boxes_gt = []
        with open(args.data_info_path, newline='') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                if(int(row['split_index'])in training_splits):
                    self.imgs.append(row['hashed_prefix']+".jpg")
                    self.boxes_gt.append(row['hashed_prefix']+".xml")
        self.index_dict = {}
        for i,name in enumerate(self.boxes_gt):
            prefix = name.split('.')[0]
            self.index_dict[i] = prefix
    
    def __getitem__(self, idx):
        img_path = os.path.join(args.dataset_dir, "jpg", self.index_dict[idx]+".jpg")
        xml_path = os.path.join(args.dataset_dir, "xml", self.index_dict[idx]+".xml")
        
        img = Image.open(img_path).convert("RGB")

        target = create_dictinary(xml_path)
        
        target['image_id'] = torch.tensor([idx])
        boxes = target['boxes']
        num_objs = len(target['boxes'])
        area = (boxes[:, 3] - boxes[:, 1]) * (boxes[:, 2] - boxes[:, 0])

        target['area'] = area
        iscrowd = torch.zeros((num_objs,), dtype=torch.int64)
        target['iscrowd'] = iscrowd

        target['image_id'] = torch.tensor([idx])

        if self.train:
            img = self.transforms_1(img)
        
        img, target = self.transforms_2(img,target)  

        return img, target
    
    def __len__(self):
        return len(self.imgs)

def main():
    print("running this python file is just for testing whether build_dataset.py is working correctly.")
    print("a normal image will be displayed if the dataset is loaded successfully.")

    evaluation_set = 0
    arabic_book_dataset = training_detection_dataset(evaluation_set,train=True)
    tpi = torchvision.transforms.ToPILImage()
    img_show = tpi(arabic_book_dataset[42][0])
    print("target annotation: {}".format(arabic_book_dataset[42][1]))
    img_show.show()

if __name__ == "__main__":
    main()



