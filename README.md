# mastersdissertation

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
This code is part of **[https://github.com/mmr12/MIMIC-III-sepsis-3-labels]**.  

## 4️⃣ Installing pgvector  

To enable vector search capabilities in **PostgreSQL**, I installed **pgvector**:  

🔗 Official Repository: [pgvector](https://github.com/pgvector/pgvector)  

Follow the installation instructions in the repository to set it up for your PostgreSQL database.

## 5️⃣ Extracting Sentences from Clinical Notes  

To extract sentences from each **medical note** and perform **NLP preprocessing**, I used the following repository:  

🔗 [MIMIC Tokenize](https://github.com/wboag/mimic-tokenize/tree/master)  

This repository provides tools for tokenizing clinical text, making it easier to apply **Natural Language Processing (NLP) techniques**.

