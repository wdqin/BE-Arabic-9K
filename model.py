# the code is developed based on: https://colab.research.google.com/github/pytorch/vision/blob/temp-tutorial/tutorials/torchvision_finetuning_instance_segmentation.ipynb
# modified by Wenda Qin 7/2/2021
import torchvision
from torchvision.models.detection.faster_rcnn import FastRCNNPredictor

def initialize_faster_rcnn_model():
	model = torchvision.models.detection.fasterrcnn_resnet50_fpn(pretrained=True)
	num_classes = 3
	in_features = model.roi_heads.box_predictor.cls_score.in_features
	model.roi_heads.box_predictor = FastRCNNPredictor(in_features, num_classes)
	aspect_ratios = (0.5, 1.0, 2.0)
	aspect_ratios = (aspect_ratios,) * len(model.rpn.anchor_generator.sizes)
	model.rpn.anchor_generator.aspect_ratios = aspect_ratios
	return model
	

