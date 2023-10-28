from sklearn.linear_model import LinearRegression
import matplotlib.pyplot as plt
import numpy as np


"""
Format du file:
First column with the digital value of thje potentiometer (0-1023)
Second column with the angle value measured (0-180)
"""
data = np.loadtxt('calibration.txt')


X = data[:, 0]
y = data[:, 1]

X=X.reshape(-1,1)
y=y.reshape(-1,1)



reg = LinearRegression().fit(X, y)


print("The coeeficient is: ", reg.coef_)
print("The intercept is: ", reg.intercept_)


y_pred = reg.predict(X)


plt.scatter(X, y, color="black")
plt.ylabel("angle(deg)")
plt.xlabel("Value of arduino analog read")
plt.plot(X,y_pred , color="blue", linewidth=3)



plt.show()
