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
        # print(weights.size,weights.shape)
        if "conv" in name:
            channels = weights.shape[3]
            num_filters = weights.shape[4]
            window = weights.shape[1]
            # f.write(str(window)+","+str(window)+","+str(channels)+","+str(num_filters)+"\n")
            for n in range(0,num_filters):
                for k in range(0,channels):
                    for i in range(0,window):
                        for j in range(0,window):
                            x = weights[0][i][j][k][n]
                            x = int((x+1)/2)
                            f.write(str(x))
                        # f.write("\n")
                    # f.write("\n")

        elif "dense" in name:
            output_size = weights.shape[2]
            input_size = weights.shape[1]
            # f.write(str(input_size)+","+str(output_size)+"\n")
            for k in range(0,output_size):
                # f.write("index "+str(i)+": ")
                for i in range(0,input_size):
                    x = weights[0][i][k]
                    x = int((x+1)/2)
                    f.write(str(x))
                # f.write("\n")s
        # print(weights)
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
