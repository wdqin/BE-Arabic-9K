#added by Wenda Qin, 7/7/2021 
import os
import csv
from param import args
from shutil import copyfile


RES_DIR = "./results/"
def get_evaluation_data(data_info):
    evaluation_data_list = []
    with open(data_info, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            if str(row['split_index']) == str(args.evaluation_set):
                evaluation_data_list.append(row['hashed_prefix'])
    return evaluation_data_list
def main():
    evaluation_data_list = get_evaluation_data(args.data_info_path)
    if not os.path.exists(RES_DIR+args.eval_name+"-"+str(args.evaluation_set)):
        os.makedirs(RES_DIR+args.eval_name+"-"+str(args.evaluation_set))
    else:
        print("warning: the folder with evaluation name exists, evaluation might not be successful if there have already been other data within the folder.")
    evaluation_image_dir = RES_DIR+args.eval_name+"-"+str(args.evaluation_set)+"/jpg/"
    evaluation_prediction_dir = RES_DIR+args.eval_name+"-"+str(args.evaluation_set)+"/xml/"
    evaluation_groundtruth_dir = RES_DIR+args.eval_name+"-"+str(args.evaluation_set)+"/gt/"
    if not os.path.exists(evaluation_image_dir):
        os.makedirs(evaluation_image_dir)
    if not os.path.exists(evaluation_prediction_dir):
        os.makedirs(evaluation_prediction_dir)
    if not os.path.exists(evaluation_groundtruth_dir):
        os.makedirs(evaluation_groundtruth_dir)
    image_dir = args.dataset_dir+"/jpg/"
    assert os.path.exists(image_dir), "{} does not exists, please check if your dataset images are saved here".format(image_dir)
    result_dir = RES_DIR+"/xml/"
    assert os.path.exists(result_dir), "{} does not exists, please check if your model prediction xmls are saved here".format(result_dir)
    gt_dir = args.dataset_dir+"/xml/"
    assert os.path.exists(gt_dir), "{} does not exists, please check if your dataset ground truth xmls are saved here".format(gt_dir)
    for datum_prefix in evaluation_data_list:
        src_name_image = image_dir+datum_prefix+".jpg"
        src_name_result = result_dir+datum_prefix+".xml"
        src_name_gt = gt_dir+datum_prefix+".xml"

        dst_name_image = evaluation_image_dir+datum_prefix+".jpg"
        dst_name_result = evaluation_prediction_dir+datum_prefix+".xml"
        dst_name_gt = evaluation_groundtruth_dir+datum_prefix+".xml"

        copyfile(src_name_image, dst_name_image)
        copyfile(src_name_result, dst_name_result)
        copyfile(src_name_gt, dst_name_gt)
    print("evaluation preparation is done.")


if __name__ == "__main__":
    main()



