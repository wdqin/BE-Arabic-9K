flag="
      --data_info_path data_info.csv
      --evaluation_set 1
      --dataset_dir output_data
      --eval_name testing_model
      "

CUDA_VISIBLE_DEVICES=0 python3 eval_prep.py $flag 
