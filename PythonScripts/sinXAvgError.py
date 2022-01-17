import numpy as np
import matplotlib.pyplot as plt

savedFile = open("Tests\Data\sinAvgError.txt", "r")
li = []
for line in savedFile:
    li.append(list(map(float, line.split(" "))))

h_values, error_values = tuple(li)

plt.yscale('log')
plt.xscale('log')
plt.plot(h_values, error_values, '-o', label="error vs H")
plt.plot(h_values, np.power(h_values, 2), '-x', label="h*h vs h")
plt.xlabel('h Values')
plt.ylabel('Avg Error')
plt.title('Sin(X) Derivative test')
plt.legend()
#plt.savefig(fname="PythonScripts\sinXAvgErr_LogScale", dpi=1000)
plt.show()
