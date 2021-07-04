# README 
This is the repository for scanned Arabic book/document dataest BE-Arabic-9K. A fine-tuned Faster R-CNN model implemented is also provided for benchmark. The author for the coding part is currently on an internship until May. Thus, the code and data will be released approximately in late-May or mid-June.

# DOWNLOAD:
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

# FFRA MODEL TRAINING:
## Environment Setup
### File/folder Setup
Please make sure the labeled data folder is downloaded and unzipped in the same directory with the code. Generally, your folder should look like this:
```
BE-Arabic-9k Index.xlsx  

dataset.py             

param.py         

train.py

README.md                

engine.py              

post_process.py  

transforms.py

coco_eval.py             

eval.py                

results          

utils.py

coco_utils.py            

generate_data_pair.py  

test.bash

data_info.csv            

model.py               

train.bash
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

## Running Training Script
To train a FFRA model under the default setting, simply run:

```
bash train.bash
```
You could change and adjust settings and hyperparameters in training.bash for your further needs.

## Getting the results on a specific evaluation set

To get the prediction of the text/non-text boxes of the evluation set images from your trained model, you need to install the opencv library first, one way to do that is to run the following command:

```
pip install opencv-python
```

If you have edited anything in train.bash, e.g. the name of the trained model, please change that accordingly in test.bash as well. Also please make sure that /results/jpg and /results/xml directories exist with the code (or you should adjust the parameters in test.bash based on your changes). If you haven't changed anything, or all the changes have been made in test.bash, run:

```
bash test.bash
```

You should be able to see visualization images generated in results/jpg/ and the bounding box predictions written in a .xml format in results/xml.

# UPDATES:
7/4/2021: FFRA obtaining results code uploaded.

7/2/2021: FFRA training code uploaded.

7/1/2021: labeled 9K image data published.

5/18/2021: unlabeled 9K image data published.

# TODOs:
1. Releasing the dataset including ~9000 images for BE-Arabic-9K. including 1800 manually-labeled data. The rest of the data will be semi-annotated by the trained fine-tuned Faster R-CNN (as provided in 2.). In additon, another set of 300 manually-labeled images will be only provided with image input for potential testing/challenge in the future. (late May)
2. Releasing the code for training a fine-tuned Faster R-CNN as benchmark. A pre-trained model trained with the 1800 manually-label data will also be provided. (early June).
