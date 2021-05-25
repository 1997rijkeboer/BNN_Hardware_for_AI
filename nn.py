import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf

from tensorflow.keras.datasets import mnist

def show_data(train_images, train_labels, test_images, test_labels):

    print('MNIST Dataset Shape:')
    print('X_train: ' + str(train_images.shape))
    print('Y_train: ' + str(train_labels.shape))
    print('X_test:  '  + str(test_images.shape))
    print('Y_test:  '  + str(test_labels.shape))

    class_names = ['0', '1', '2', '3', '4',
                   '5', '6', '7', '8', '9']
    plt.figure(figsize=(10,10))
    for i in range(25):
        plt.subplot(5,5,i+1)
        plt.xticks([])
        plt.yticks([])
        plt.grid(False)
        plt.imshow(train_images[i], cmap=plt.cm.binary)
        plt.xlabel(class_names[train_labels[i]])
    plt.savefig('train_data.png')


def plot_image(i, predictions_array, true_label, img):
    class_names = ['0', '1', '2', '3', '4','5', '6', '7', '8', '9']
    true_label, img = true_label[i], img[i]
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    plt.imshow(img, cmap=plt.cm.binary)

    predicted_label = np.argmax(predictions_array)
    if predicted_label == true_label:
        color = 'blue'
    else:
        color = 'red'

    plt.xlabel("{} {:2.0f}% ({})".format(class_names[predicted_label],
                                100*np.max(predictions_array),
                                class_names[true_label]),
                                color=color)

def plot_value_array(i, predictions_array, true_label):
    true_label = true_label[i]
    plt.grid(False)
    plt.xticks(range(10))
    plt.yticks([])
    thisplot = plt.bar(range(10), predictions_array, color="#777777")
    plt.ylim([0, 1])
    predicted_label = np.argmax(predictions_array)

    thisplot[predicted_label].set_color('red')
    thisplot[true_label].set_color('blue')


def show_predictions(predictions, test_images, test_labels):

    plt.figure(figsize=(10,10))
    for i in range(25):
        plt.subplot(5,5,i+1)
        plt.xticks([])
        plt.yticks([])
        plt.grid(False)
        plt.imshow(test_images[i], cmap=plt.cm.binary)
        plt.xlabel(np.argmax(predictions[i]))
    plt.savefig('test_data.png')

    num_rows = 5
    num_cols = 3
    num_images = num_rows*num_cols
    plt.figure(figsize=(2*2*num_cols, 2*num_rows))
    for i in range(num_images):
      plt.subplot(num_rows, 2*num_cols, 2*i+1)
      plot_image(i, predictions[i], test_labels, test_images)
      plt.subplot(num_rows, 2*num_cols, 2*i+2)
      plot_value_array(i, predictions[i], test_labels)
    plt.tight_layout()
    plt.savefig('accuracy.png')


def main():

    (train_images, train_labels), (test_images, test_labels) = mnist.load_data()

    # show_data(train_images, train_labels, test_images, test_labels)

    model = tf.keras.Sequential([
        #input layer
        tf.keras.layers.Flatten(input_shape=(28, 28)),
        #intermediate ;ayers
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dense(10)
    ])

    #model parameters
    model.compile(optimizer='adam',
                  loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
                  metrics=['accuracy'])

    #Feed data
    model.fit(train_images, train_labels, epochs=10)
    #summary of the model
    model.summary()
    #train the nn
    test_loss, test_acc = model.evaluate(test_images,  test_labels, verbose=2)
    print('\nAccuracy:', test_acc)

    # #output layer
    probability_model = tf.keras.Sequential([model, tf.keras.layers.Softmax()])

    #prediction
    predictions = probability_model.predict(test_images)
    print("prediction 0: ", np.argmax(predictions[0]))
    show_predictions(predictions, test_images, test_labels)

main()
