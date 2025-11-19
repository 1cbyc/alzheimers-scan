# Alzheimer Scanner - For Alzheimer's Disease Detection and Classification


Working on early detection of Alzheimer's Disease using deep learning and ML approaches, with optimization via CSA (Crow Search Algorithm). Since AD is progressive and gets harder to treat later on, catching it early could help a lot of people. Using MRI scans to classify whether patients might develop AD.

After testing different approaches, CSA with ML algorithms gave the best results.

## Methodology

**Data:** Used MRI scan images from ADNI (Alzheimer's Disease Neuroimaging Initiative) in .nii format. Selected middle slices along the y-direction (most informative), converted to grayscale.

**Methods:**

1. **CNN for MRI classification**
   - Two 2D conv layers: first with 6 filters (5x5), second with 16 filters (5x5)
   - Four fully-connected layers: 1000 → 120 → 84 → 2 output nodes
   - Input shape: 1x260x260, outputs: 6x256x256 → 16x252x252 → FC layers

2. **ML with Crow Search optimization**
   - Tested SVM, Decision Trees, Random Forest, KNN
   - Used GridSearchCV for hyperparameter tuning

## Research Reference I used
https://www.inderscience.com/offers.php?id=117272

---

**Author:** Isaac Emmanuel  
**GitHub:** [@1cbyc](https://github.com/1cbyc)  
**Website:** [nsisong.com](https://nsisong.com)
