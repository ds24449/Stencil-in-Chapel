import numpy as np
import matplotlib.pyplot as plt

savedFile = open("Tests\Temporal\sinWaveTime.txt", "r")
li = []
for line in savedFile:
    li.append(list(map(float, line.split(" "))))

plt.plot(li[0], np.sin(li[0]))

for i in range(1, 5):
    plt.plot(li[0], li[i])

plt.show()
