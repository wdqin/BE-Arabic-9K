# README 
This is the repository for scanned Arabic book/document dataest BE-Arabic-9K. A fine-tuned Faster R-CNN model implemented is also provided for benchmark. The author for the coding part is currently on an internship until May. Thus, the code and data will be released approximately in late-May or mid-June.

# DOWNLOAD:
<!---
## Unlabeled data: 
The following wget commands allow downloading source PDFs and PNGS for all available but unlabeled images in BE-Arabic-9K. The PDF one contains all BE-Arabic-9K book pdf scans. The PNG one contains the split PNG image for each page in the pdf scans. The BE-Arabic-9k Index.xlsx file within PDF .zip file describes the organization of the pdf scan in each unzipped folder. pdf2png_9K.csv within the PNG .zip file describes the pairing relation between the name-hashed image and the coresponding page in its PDF part.  

### Raw PDFs collected data: 
```
wget ftp://csr.bu.edu/Data-BE-Arabic-9K/BE-Arabic-9K-pdf-unlabeled.zip
```
### PNG image data generated from PDFs: 
```
wget ftp://csr.bu.edu/Data-BE-Arabic-9K/BE-Arabic-9K-png-unlabeled.zip
```
## Labeled data: 
Here we provide the labeled data used for validation/training/testing. There are 6 splits of data in total. We use split 0 for the evaluation split during validation experiment. Splits 1-5 are used for 4 v.s. 1 cross-validation training/testing.
### Labeled data for validation/training/testing: 
```
wget ftp://csr.bu.edu/Data-BE-Arabic-9K/BE-Arabic-9K-labeled.zip
```
## Pretrained model
Here we provide the pre-trained model we trained for validation. 
```
wget ftp://csr.bu.edu/Data-BE-Arabic-9K/test_model
```
Simply moving it to the root directory of this repository and follow the instruction from 'Getting the results on a specific evaluation set' should be able to get you the evaluation results shown in the benchmark section.
--->

# FFRA MODEL TRAINING/EVALUATION:
## Environment Setup
### File/folder Setup
Please make sure the labeled data folder is downloaded and unzipped in the same directory with the code. Generally, your folder should look like this:
```
BE-Arabic-9k Index.xlsx  
demo.csv               
get_result.bash  
train.bash
README.md                
demo.png               
get_result.py    
train.py
coco_eval.py             
engine.py              
model.py         
transforms.py
coco_utils.py            
eval_prep.bash         
param.py         
utils.py
data                     
eval_prep.py           
post_process.py
data_info.csv            
evaluation_code        
results
dataset.py               
generate_data_pair.py  
run
```
### Library Setup
Here we provide a way of using Anaconda for environment setup. The version of Anaconda we used is 4.9.2

first, we create a virtual environment with python 3.6 installed:

```
conda create --name arabicFFRA python=3.6
``` 
enter the created virtual environment then.

```
conda activate arabicFFRA
```
There are two things mainly needed to be installed, namely pytorch (recent version should work just fine) and pycocotools:

```
conda install pytorch torchvision torchaudio cudatoolkit=11.1 -c pytorch -c nvidia

pip install cython

pip install -U 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'
```
### Matlab Installation
Since our evaluation code is written in Matlab, you will need a Matlab software to run the evaluation. To be notice that our code is developed in an older version of Matlab, thus the latest version of Matlab will not work as the differences in certain functions/libraries we used. The Matlab version we are using is Matlab 2017a.

## Running Training Script
To train a FFRA model under the default setting, simply run:

```
bash run/train.bash
```
You could change and adjust settings and hyperparameters in training.bash for your further needs.

## Getting the results on a specific evaluation set

To get the prediction of the text/non-text boxes of the evluation set images from your trained model, you need to install the opencv library first, one way to do that is to run the following command:

```
pip install opencv-python
```

If you have edited anything in train.bash, e.g. the name of the trained model, please change that accordingly in test.bash as well. Also please make sure that /results/jpg and /results/xml directories exist with the code (or you should adjust the parameters in test.bash based on your changes). If you haven't changed anything, or all the changes have been made in test.bash, run:

```
bash run/get_result.bash
```

You should be able to see visualization images generated in results/jpg/ and the bounding box predictions written in a .xml format in results/xml.

## Evaluation on your prediction results
Our evaluation code is developed on Matlab, so there's an additional process to prepare the data in a suitable format that the Matlab code could read. To do this, simply run 'eval_prep.bash':
```
bash run/eval_prep.bash
```
What it does is to create a folder containing needed image, prediction, ground truth files in the folder "results/", the name of the folder is decided in 'eval_prep.bash'. Say the name is "test_model", the folder name will be "test_model-x", where x is the split index you are evaluating (e.g. the validation set is 0). The script will copy the evaluation set data to the folder, which will be used by the Matlab code. Here we want to point out that please don't mix the data in one folder with the another that is not in the same evaluation set, as that will lead to inaccurate evaluation results on the specific evaluation set.

After the preparation is done, you could go to the 'evaluation_code' folder and run your Matlab:
```
cd evaluation_code

matlab
```
Inside your Matlab, open 'Run_Seg_Eval.m'. There is one more thing to do before running evaluation, that is to set the path of the folder we just created. The three variables needed to be edited are: "ResultsPath","XMLPath","IMGPath" at the beginning of the code. On default, the folder path is '../results/testing_model-0/xml/'. If you didn't change anything in eval_prep.bash, you should be fine without editing anything. However, say your 'eval_name' parameter set in eval_prep.bash is set to "FFRA" and your evaluation set is 2, the folder created by the eval_prep.bash in "/results/" should be "FFRA-2" accordingly. You should change '../results/testing_model-0/xml/' to '../results/FFRA-2/xml/' in this case (Please noted that for IMGPath, it is '/jpg/' instead of '/xml/'). 
Finally, run the code and you should be able to see results at the end of the console window when it is finished.

Please noted there will always be subtle differences in the result for models trained in different environments because of the used hardware, library version etc.

# Benchmark
Here we provide the benchmark results of the 'test_model', a pretrained FFRA model. Please refer to our paper 'Extracting text from scanned Arabic books: a large-scale benchmark dataset and a fine-tuned Faster-R-CNN model' for the explanation of the metrics.

| Evaluation Set | OSE | USE | MSE | FA | CS | rho | F1 Score (%) | Accuracy (%) | TPA (%) | FgPA (%) |
| ---- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| Validation | 0.05 | 1.21 | 0.10 | 0.04 | 2.13 | 0.27 | 98.95 | 99.08 | 96.89 | 96.05 |


# UPDATES:
7/9/2021: FFRA evaluation benchmark uploaded, most of the used code has been updated and uploaded, v1.0 out.

7/7/2021: FFRA evaluation code uploaded.

7/4/2021: FFRA obtaining results code uploaded.

7/2/2021: FFRA training code uploaded.

7/1/2021: labeled 9K image data published.

5/18/2021: unlabeled 9K image data published.

# CITATION:
If you use or discuss our BE-Arabic-9K dataset or FFRA baseline benchmark, please cite our paper:

```
@article{elanwar2021extracting,
  title={Extracting text from scanned Arabic books: a large-scale benchmark dataset and a fine-tuned Faster-R-CNN model},
  author={Elanwar, Randa and Qin, Wenda and Betke, Margrit and Wijaya, Derry},
  journal={International Journal on Document Analysis and Recognition (IJDAR)},
  pages={1--14},
  year={2021},
  publisher={Springer}
}
```

# TODOs:
1. Build a dump with a link of older code for reproducing the original results.
2. Adding comments to the code.
