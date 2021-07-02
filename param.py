import argparse
import os
import torch

class Param:
    def __init__(self):
        self.parser = argparse.ArgumentParser(description="")

        #files location configuration
        self.parser.add_argument('--data_info_path', type=str, default='data_info.csv', help='the path for split information .csv file')
        self.parser.add_argument('--dataset_dir', type=str, default='data', help='the directory for dataset')

        #training setting configuration
        self.parser.add_argument('--lr', type=float, default=0.005, help='learning rate')
        self.parser.add_argument('--momentum', type=float, default=0.9, help='momentum rate')
        self.parser.add_argument('--weight_decay', type=float, default=0.0005, help='weight decay')
        self.parser.add_argument('--step_size', type=int, default=3, help='step size')
        self.parser.add_argument('--gamma', type=float, default=0.1, help='gamma')
        self.parser.add_argument('--num_epochs', type=int, default=100, help='num_epochs')

        #training set configuration
        self.parser.add_argument('--evaluation_set', type=int, default=0, help='evaluation set, 0 for validation set 0, 1-5 for cross validation')
        
        self.args = self.parser.parse_args()

param = Param()
args = param.args

