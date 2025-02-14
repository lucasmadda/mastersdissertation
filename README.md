# mastersdissertation  

This repository contains the code for the experiments conducted as part of my **MSc Dissertation in Industrial Engineering at PUC-Rio**.  

## 📌 Dissertation Title  
**Evaluating Ontologically-Aware Large Language Models: An Experiment in Sepsis Prediction**  

The project explores the integration of **ontology-based techniques** with **Large Language Models (LLMs)** to improve **sepsis prediction** using data from the **MIMIC-III** clinical dataset. The repository includes mostly all necessary scripts for data preprocessing, feature extraction, model training, and evaluation.  


## 1️⃣ Downloading MIMIC-III

To download **MIMIC-III**, use the following `wget` command:

```bash
wget -r -N -c -np --user <<your_username>> --ask-password https://physionet.org/files/mimiciii/1.4/
```

⚠️ **Important:** Access to **MIMIC-III** requires credentials.  
Make sure you are registered on [PhysioNet](https://physionet.org/) and have permission to access the dataset.

## 2️⃣ Setting Up PostgreSQL 16

With **PostgreSQL 16** installed, follow the tutorial from the official repository:  

🔗 [MIMIC-III PostgreSQL Setup Guide](https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/buildmimic/postgres)

## 3️⃣ Identifying Sepsis Cases  

To define **which patients had sepsis and when**, I used the repository below:  

### **MIMIC-III Sepsis-3 Labels**  
An SQL and Python-based implementation for extracting **Sepsis-3** labels in the MIMIC-III dataset.  
This code is part of **🔗 [MIMIC-III Sepsis-3 Labels](https://github.com/mmr12/MIMIC-III-sepsis-3-labels)**.  

## 4️⃣ Installing pgvector  

To enable vector search capabilities in **PostgreSQL**, I installed **pgvector**:  

🔗 Official Repository: [pgvector](https://github.com/pgvector/pgvector)  

Follow the installation instructions in the repository to set it up for your PostgreSQL database.

## 5️⃣ Extracting Sentences from Clinical Notes  

To extract sentences from each **medical note** and perform **NLP preprocessing**, I used the following repository:  

🔗 [MIMIC Tokenize](https://github.com/wboag/mimic-tokenize/tree/master)  

This repository provides tools for tokenizing clinical text, making it easier to apply **Natural Language Processing (NLP) techniques**.

## 6️⃣ Generating Clinical Note Embeddings  

The script **`create_embeddings.py`** processes clinical notes by generating sentence embeddings. These embeddings are later stored in a **PostgreSQL database** using **pgvector**, with `psycopg` or another database integration tool.  

To execute the script, use the following command:  

```bash
python create_embeddings.py [-c | --from_checkpoint]
```

If `--from_checkpoint` is set to `True`, the script resumes from the last saved checkpoint.  

## 7️⃣ Materialized Views for MIMIC-III  

The script **`materialized_mimic_views.sql`** provides the necessary queries to create **materialized views** that store hourly information on **vital signs, laboratory results, and blood tests**.  

These views enable efficient retrieval of time-series clinical data from the MIMIC-III dataset.  

To apply the script, run:  
```bash
psql -U <your_user> -d <your_database> -f materialized_mimic_views.sql
```

This process ensures that key clinical data is precomputed and readily available for analysis.  

## 8️⃣ Data Processing  

A **CSV file extracted from the database** was used for data processing. The script applies various transformations to clean and structure the data.  

⚠️ **Note:** Outputs have been removed due to the sensitive nature of MIMIC data.  

For detailed processing steps, refer to **`treating_data.ipynb`** in this repository.

## 9️⃣ Converting Data to NPZ Format  

The extracted data is converted into **NPZ format**, optimized for efficient storage and model training.  

- The script **`create_npz_data.ipynb`** handles the conversion process.  
- The resulting NPZ files are processed by **`data_handler.py`**, which correctly splits the data into folds and ensures it is in the appropriate format for model input.  

This approach follows the methodology from the repository:  
🔗 [Rep (GitHub)](https://github.com/PeterChe1990/GRU-D)  

This step is essential for preparing the dataset for training and evaluation.  

## 🔟 Training the Model  

The model is trained using **`train_model.py`**.  

Run:  
```bash
python train_model.py
```

Refer to the script for details.  

## 1️⃣1️⃣ Post-Training Analysis  

For analyses conducted after model training, please contact me via email:  

📩 **lucasgomesmadda@hotmail.com**  
