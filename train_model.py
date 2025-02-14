import tensorflow as tf
from tensorflow.keras import backend as K
from tensorflow.keras import layers, models, Input, regularizers
from tensorflow.python.keras.layers.recurrent import _generate_dropout_mask
from tensorflow.keras.callbacks import EarlyStopping
import numpy as np
import datetime

import os
os.environ['TF_CPP_MIN_LOG_LEVEL']='2'



from data_handler import DataHandler

file_path = 'data/processed_data.csv'

# get dataset
dataset = DataHandler(
    data_path=file_path, 
    label_name='taskname', 
    max_steps=60,
    max_timestamp=60, fill_nan=True
)

input_dim = dataset.input_dim
output_activation = dataset.output_activation
output_dim = dataset.output_dim
batch_size = 512

def create_model(input_dim, output_activation, output_dim, recurrent_dim = [64,32], hidden_dim = [32,16]):
    tf.keras.utils.set_random_seed(
    5521
    )
    # First input: measured values

    input_x = Input(shape=(None, input_dim))
    input_m = Input(shape=(None, input_dim))
    input_s = Input(shape=(None, 1))

    

    inputs_list = [input_x, input_m, input_s]

    concatenated = layers.concatenate([input_x, input_m])

    x = layers.GRU(recurrent_dim[0],
                   return_sequences=True,
                   activation='tanh',
                   recurrent_activation='sigmoid',
                   dropout = 0,
                   recurrent_dropout = 0,
                   )(concatenated)

    for i, rd in enumerate(recurrent_dim[1:]):

        x = layers.GRU(rd,
                       return_sequences=i < len(recurrent_dim) - 2,
                       dropout = 0,
                       recurrent_dropout = 0)(x)
        
    # x = layers.Dropout(.3)(x)

    for hd in hidden_dim:        
        x = layers.Dense(units=hd,
                kernel_regularizer=regularizers.l2(1e-4), activation = 'relu')(x)
            
    x = layers.Dense(output_dim, activation=output_activation)(x)
    output_list = [x]

    # Create the model
    # model = models.Model(inputs=[input_values, input_mask, input_additional], outputs=output)
    model = models.Model(inputs=inputs_list, outputs=output_list)

    # Compile the model

    return model

optimizer = tf.keras.optimizers.legacy.Adam(learning_rate=0.0005)

for i_fold in range(dataset.folds):
        
    # Create the model
    model = create_model(input_dim=input_dim, output_dim=output_dim, output_activation=output_activation)

    model.compile(optimizer=optimizer, loss='binary_crossentropy',
        metrics = [tf.keras.metrics.AUC(name='AUC'), 
                tf.keras.metrics.AUC(curve='PR', name='AUPRC')])
    
    if i_fold == 0:
        model.summary()

    log_dir = "logs/fit/non_semantic_fold_{}".format(i_fold)
    checkpoint_filepath = 'non_semantic_checkpoint_fold_{}.h5'.format(i_fold)
    tensorboard_callback = tf.keras.callbacks.TensorBoard(log_dir=log_dir, histogram_freq=1)
    earlystopping_callback = EarlyStopping(patience=10, min_delta = 0.001, restore_best_weights=True, mode = "max", monitor = "val_AUC")
    model_checkpoint_callback = tf.keras.callbacks.ModelCheckpoint(filepath=checkpoint_filepath,
                                                                   save_weights_only=True,
                                                                   monitor='val_AUC',
                                                                   mode='max',
                                                                   save_best_only=True)
    model.fit_generator(generator = dataset.training_generator(i_fold=i_fold, batch_size=batch_size),
            validation_data = dataset.validation_generator(i_fold=i_fold, batch_size=batch_size),
            steps_per_epoch = dataset.training_steps(i_fold=i_fold, batch_size=batch_size),
            validation_steps = dataset.validation_steps(i_fold=i_fold, batch_size=batch_size),
            epochs=70,
            callbacks=[tensorboard_callback,
                       earlystopping_callback,
                       model_checkpoint_callback
                    ])
    
    model.save('models/non_semantic_fold_{}.h5'.format(i_fold))