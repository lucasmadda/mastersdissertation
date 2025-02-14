import pandas as pd
import numpy as np
import os
import argparse
from tqdm import tqdm
import time
from transformers import AutoModel, AutoTokenizer
import torch

model_path = './clinical_kb_bert' # clinical kb bert model when on semantically aware scenario, clinical bert model when on semantically unaware scenario
model = AutoModel.from_pretrained(model_path)
tokenizer = AutoTokenizer.from_pretrained(model_path)

tokens = lambda batch_sentences: tokenizer(batch_sentences, padding=True, truncation=True, return_tensors='pt', max_length=40)

df = pd.read_csv('filtered_sentenced_notes_202403150058.csv')

combs = df[["icustay_id","hours_since_icu_adm"]].drop_duplicates().values
chunks = np.array_split(combs, 20000)

def mean_by_label(samples, labels):
    ''' select mean(samples), count() from samples group by labels order by labels asc '''
    weight = torch.zeros(labels.max()+1, samples.shape[0]).to(samples.device) # L, N
    weight[labels, torch.arange(samples.shape[0])] = 1
    label_count = weight.sum(dim=1)
    weight = torch.nn.functional.normalize(weight, p=1, dim=1) # l1 normalization
    mean = torch.mm(weight, samples) # L, F
    index = torch.arange(mean.shape[0]).to(samples.device)[label_count > 0]


    return mean[index]

def main(args):



    if args.from_checkpoint:
        checkpoint = os.listdir('./embeddings_chunks')
        checkpoint =  np.max([int(i.split("_")[1]) for i in checkpoint])

    else:
        with open('log_semantic.txt', 'w', encoding="utf-8") as f:
            f.write('chunk, num_sentences, time spent(s)\n')
            f.close()
        checkpoint = 0

    for chunk_number, chunk in enumerate(tqdm(chunks)):

        if chunk_number <= checkpoint:
            continue

        start = time.time()
        icustay_ids = chunk[:, 0]
        hours_since_adms = chunk[:, 1]

        temp_df = df[(df["icustay_id"].isin(icustay_ids)) & (df["hours_since_icu_adm"].isin(hours_since_adms))].sort_values(
            ["icustay_id", "hours_since_icu_adm"], ascending=[True, True])

        samples = model(**tokens(temp_df["text"].to_list())).last_hidden_state[:, 0, :]

        labels = torch.LongTensor(pd.factorize(temp_df[["icustay_id", "hours_since_icu_adm"]].apply(tuple, axis=1))[0])

        indexes = pd.factorize(temp_df[["icustay_id", "hours_since_icu_adm"]].apply(tuple, axis=1))[1]

        res = pd.DataFrame(index=pd.factorize(temp_df[["icustay_id", "hours_since_icu_adm"]].apply(tuple, axis=1))[1],
                           data=mean_by_label(samples, labels).detach())

        res.to_csv('./embeddings_chunks/chunk_{}'.format(chunk_number))

        time_spent = time.time() - start

        with open('log_semantic.txt', 'a', encoding="utf-8") as f:

            f.write('{0}, {1}, {2}\n'.format(chunk_number, len(temp_df), time_spent))
            f.close()

def parse_arg():
    parser = argparse.ArgumentParser()
    parser.add_argument("-c","--from_checkpoint",
                        help="True if running from checkpoint",
                        default=False)
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_arg()
    main(args)
