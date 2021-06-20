import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf
import larq as lq

from tensorflow.keras.datasets import mnist

def save_results(accuracy, loss):

    plt.figure(0)
    plt.plot(accuracy)
    # plt.plot(history.history['val_accuracy'])
    plt.title('model accuracy')
    plt.ylabel('accuracy')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')
    plt.savefig('accuracy.png')

    plt.figure(1)
    plt.plot(loss)
    # plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('loss')
    plt.xlabel('epoch')
    plt.legend(['train', 'test'], loc='upper left')
    plt.savefig('loss.png')

def save_weights(model):
    f = open("../hardware/bnn_weights.txt", "w")
    for layer in model.layers:
        name = layer.get_config()['name']
        weights = np.array(layer.get_weights())
        if "conv" in name:
            channels = weights.shape[3]
            num_filters = weights.shape[4]
            window = weights.shape[1]
            for n in range(0,num_filters):
                for k in range(0,channels):
                    for i in range(0,window):
                        for j in range(0,window):
                            x = weights[0][i][j][k][n]
                            x = int((x+1)/2)
                            f.write(str(x))

        elif "dense" in name:
            output_size = weights.shape[2]
            input_size = weights.shape[1]
            last_layer = model.get_layer('max_pooling2d_1')
            row_size = last_layer.output_shape[1]
            column_size = last_layer.output_shape[2]
            channels = last_layer.output_shape[3]
            # print(channels*row_size*column_size)
            # print(input_size)
            for k in range(0,output_size):
                for i in range(0,row_size):
                    for z in range(0,channels):
                        for j in range(0,column_size):
                            #index = (row_size*column_size*z)+(column_size*i)+j
                            index = channels*column_size*i + channels*j + z
                            x = weights[0][index][k]
                            x = int((x+1)/2)
                            f.write(str(x))
    f.close()

def main():

    num_classes = 10
    input_shape = (28, 28, 1)

    (X_train, Y_train), (X_test, Y_test) = mnist.load_data()
    X_train = X_train.reshape((60000, 28, 28, 1))
    X_test = X_test.reshape((10000, 28, 28, 1))
    X_train, X_test = X_train / 127.5 - 1, X_test / 127.5 - 1

    kwargs = dict(input_quantizer="ste_sign",
              kernel_quantizer="ste_sign",
              kernel_constraint="weight_clip")

    model = tf.keras.Sequential()
    model.add(lq.layers.QuantConv2D(16, (3, 3),use_bias=False,
                                input_shape=input_shape, **kwargs))
    model.add(tf.keras.layers.MaxPooling2D((2, 2)))
    model.add(lq.layers.QuantConv2D(32, (3, 3), use_bias=False, **kwargs))
    model.add(tf.keras.layers.MaxPooling2D((2, 2)))
    model.add(tf.keras.layers.Flatten())
    # model.add(tf.keras.layers.BatchNormalization(scale=False))
    model.add(lq.layers.QuantDense(10, use_bias=False, **kwargs))
    model.add(tf.keras.layers.Activation("softmax"))

    optimizer = lq.optimizers.CaseOptimizer(
    (lq.optimizers.Bop.is_binary_variable, lq.optimizers.Bop()),
    default_optimizer=tf.keras.optimizers.Adam(0.01),
    )

    model.compile(optimizer=optimizer,
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'])

    lq.models.summary(model)

    history = model.fit(X_train, Y_train, epochs=2, shuffle=True, batch_size=64)
    test_loss, test_acc = model.evaluate(X_test, Y_test)
    predictions = model.predict(X_test)

    print('\nAccuracy:', test_acc)
    print("prediction: ", np.argmax(predictions[0]))
    save_results(history.history['accuracy'], history.history['loss'])
    save_weights(model)

main()
