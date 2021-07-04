import argparse
import os
import torch

class Param:
    def __init__(self):
        self.parser = argparse.ArgumentParser(description="")
        
        #training parameters
        self.parser.add_argument('--lr', type=float, default=0.005, help='learning rate')
        self.parser.add_argument('--momentum', type=float, default=0.9, help='momentum rate')
        self.parser.add_argument('--batch_size', type=int, default=4, help='batch size')
        self.parser.add_argument('--weight_decay', type=float, default=0.0005, help='weight decay')
        self.parser.add_argument('--step_size', type=int, default=3, help='step size')
        self.parser.add_argument('--gamma', type=float, default=0.1, help='gamma')
        self.parser.add_argument('--num_epochs', type=int, default=100, help='num_epochs')
        self.parser.add_argument('--evaluation_set', type=int, default=0, help='evaluation set, 0 for validation set 0, 1-5 for cross validation')
        self.parser.add_argument('--data_info_path', type=str, default='data_info.csv', help='the path for split information .csv file')
        self.parser.add_argument('--dataset_dir', type=str, default='output_data', help='the directory for dataset')

        #testing parameters
        self.parser.add_argument('--model_path', type=str, default='./testing_model', help='the path for testing model')
        self.parser.add_argument('--region_acceptance_score', type=float, default=0.8, help='confidence score threshold to accept an prediction')
        self.parser.add_argument('--i_r_threshold', type=float, default=0.2, help='a threshold for merging two overlapped predicted boxes')
        self.parser.add_argument('--visualization_output_directory', type=str, default='results/jpg', help='visualization output directory')
        self.parser.add_argument('--xml_output_directory', type=str, default='results/xml', help='xml output directory')
        self.args = self.parser.parse_args()

param = Param()
args = param.args

