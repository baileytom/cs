import matplotlib.pyplot as plt
import numpy as np

# return ndarray of the data
def read_data(filename):
    return np.loadtxt(filename, usecols = (0, 4))

def calculate_y_with_coefficients(x, coeffs):
    o = len(coeffs)
    y = 0
    for i in range(o):
        y += coeffs[i]*x**i
    return y

def polynomial_regression(degree):
    data = read_data('cars')
    mpg = data[:,0]
    weight = data[:,1]
    
    coefs = np.polyfit(weight, mpg, degree).tolist()[::-1]

    x = [n for n in range(int(min(weight)), int(max(weight)))]
    y = [calculate_y_with_coefficients(n, coefs) for n in x]

    plt.scatter(weight, mpg)
    plt.plot(x, y, 'r')
    plt.show()

while 1:
    polynomial_regression(int(input("degree: ")))
