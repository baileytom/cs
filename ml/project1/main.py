import matplotlib.pyplot as plt
import numpy as np

def read_data(filename):
    f = open(filename, "r")
    result = {}
    for line in f.readlines():
        hour, purchases = line.strip("\n").split(",")
        if purchases == 'nan': continue
        result[int(hour)] = int(purchases)
    return result

def add_scatter(data):
    plt.clf()
    plt.title('Downloads over a month')
    plt.xlabel('Hour')
    plt.ylabel('Downloads')
    plt.scatter(data.keys(), data.values())
    
def linear_regression(data):
    # Initialize values for slope intercept calculation
    sigx = sum(data.keys())
    sigy = sum(data.values())
    sigxy = sum(x*y for x, y in data.items())
    sigx_2 = sum(x*x for x in data.keys())
    sigy_2 = sum(y*y for y in data.values())
    n = len(data)
    # Calculate slope intercept
    slope = (n*sigxy - sigx*sigy) / (n*sigx_2 - sigx*sigx)
    intercept = (sigy - slope*sigx) / n
    return slope, intercept

def calculate_y_with_coefficients(x, coeffs):
    o = len(coeffs)
    y = 0
    for i in range(o):
        y += coeffs[i]*x**i
    return y

def add_line(slope, intercept):
    axes = plt.gca()
    x_vals = np.array(axes.get_xlim())
    y_vals = intercept + slope * x_vals
    plt.plot(x_vals, y_vals, '--', color='r')

def predict(slope, intercept, x_value):
    return intercept + slope*x_value
    
def show():
    plt.show()

def demo():
    # Read in & clean the data
    data = read_data("downloads.txt")

    # Show scatterplot
    add_scatter(data)
    show()

    # Calculate slope intercept of linear regression
    slope, intercept = linear_regression(data)

    # Predict downloads at noon on the fifth day of the next month
    hour = 12+24*5+len(data)
    download_prediction = predict(slope, intercept, hour)
    print("Linear regression prediction for hour {}: {}".format(hour, round(download_prediction)))

    # Show scatterplot with linear regression & predicted download point
    add_scatter(data)
    add_line(slope, intercept)
    plt.plot(hour, download_prediction, 'ro')
    show()

    # Show scatterplot with polynomial regression degree 6
    polynomial_regression(6)

def polynomial_regression(degree):
    data = read_data("downloads.txt")
    coeffs = np.polyfit(list(data.keys()), list(data.values()), degree).tolist()[::-1]
    x = list(x for x in range(800))
    y = [calculate_y_with_coefficients(x, coeffs) for x in x]
    add_scatter(data)
    plt.plot(x, y, 'r')

    # Prediction
    hour = 12+24*5+len(data)
    prediction = calculate_y_with_coefficients(hour, coeffs)
    print("Polynomial regression prediction for hour {}: {}".format(hour, round(prediction)))
    plt.plot(hour, prediction, 'ro')
        
    show()

if __name__ == "__main__":
    demo()
