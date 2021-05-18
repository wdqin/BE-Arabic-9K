# README 
This is the repository for scanned Arabic book/document dataest BE-Arabic-9K. A fine-tuned Faster R-CNN model implemented is also provided for benchmark. The author for the coding part is currently on an internship until May. Thus, the code and data will be released approximately in late-May or mid-June.

# DOWNLOAD:
## unlabel data: the following wget commands allow downloading source PDFs and PNGS for all available but unlabeled images in BE-Arabic-9K. The PDF one contains all BE-Arabic-9K book pdf scans. The PNG one contains the split PNG image for each page in the pdf scans. The BE-Arabic-9k Index.xlsx file within PDF .zip file describes the organization of the pdf scan in each unzipped folder. pdf2png_9K.csv within the PNG .zip file describes the pairing relation between the name-hashed image and the coresponding page in its PDF part.  
### 1. raw PDFs collected data: 
```
wget ftp://csr.bu.edu/Data-BE-Arabic-9K/BE-Arabic-9K-pdf-unlabeled.zip
```
### 2. PNG image data generated from PDFS: 
```
ftp://csr.bu.edu/Data-BE-Arabic-9K/BE-Arabic-9K-png-unlabeled.zip
```
# UPDATES:
5/18/2021: unlabeled 9K image data published.

# TODOs:
1. Releasing the dataset including ~9000 images for BE-Arabic-9K. including 1800 manually-labeled data. The rest of the data will be semi-annotated by the trained fine-tuned Faster R-CNN (as provided in 2.). In additon, another set of 300 manually-labeled images will be only provided with image input for potential testing/challenge in the future. (late May)
2. Releasing the code for training a fine-tuned Faster R-CNN as benchmark. A pre-trained model trained with the 1800 manually-label data will also be provided. (early June).
