flag="--dataset_dir output_data
      --data_info_path data_info.csv
      --evaluation_set 0
      --batch_size 4
      --region_acceptance_score 0.8
      --i_r_threshold 0.2
      --model_path ./testing_model
      --visualization_output_directory results/jpg
      --xml_output_directory results/xml
      "

CUDA_VISIBLE_DEVICES=0 python3 get_result.py $flag 
