flag="--dataset_dir output_data
      --lr 0.005
      --momentum 0.9
      --weight_decay 0.0005
      --step_size 3
      --gamma 0.1
      --num_epochs 100
      --evaluation_set 0
      --data_info_path data_info.csv
      --batch_size 4
      "

CUDA_VISIBLE_DEVICES=0 python3 train.py $flag 
