from shutil import copyfile
from hashlib import sha256
import os 
import csv 


image_file_count = 0
dataset_path = "./data"
split_list = os.listdir("./data")
image_file_count = 0
with open('data_info.csv','w',newline='') as csvfile:
	fieldnames = ['split_index','datum_index','hashed_prefix']
	writer = csv.DictWriter(csvfile,fieldnames = fieldnames)
	writer.writeheader()
	for split in split_list:
		split_path = dataset_path+"/"+split+"/"
		jpg_folder_path = dataset_path+"/"+split+"/jpg/"
		xml_folder_path = dataset_path+"/"+split+"/xml/"
		jpg_files = os.listdir(jpg_folder_path)
		for file in (jpg_files):
			jpg_file_path = jpg_folder_path+file
			xml_file_path = xml_folder_path+file.split('.')[0]+".xml"
			file_name = sha256(str(image_file_count).encode('utf-8')).hexdigest()
			jpg_output_file_path = "./output_data/jpg/"+file_name+".jpg"
			xml_output_file_path = "./output_data/xml/"+file_name+".xml"
			image_file_count+=1
			copyfile(jpg_file_path, jpg_output_file_path)
			copyfile(xml_file_path, xml_output_file_path)
			print("file_name: {}".format(file_name))
			writer.writerow({'split_index':int(split),'datum_index':int(file.split('.')[0]),'hashed_prefix':file_name})
# print()
# copyfile(src, dst)