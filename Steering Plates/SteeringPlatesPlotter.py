# plot splats from SteeringPlates.gem file 
# 
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import os

# read in most recent data file with pandas
filenum = []
for f in os.listdir('data'):
    filenum.append(int(f.split('-')[1].split('.')[0]))
lastfile = np.amax(filenum)
filepath = "data\\SteeringPlatesData-"+str(lastfile)+".csv"
print(filepath)
datain = pd.read_csv(filepath, sep = ',', skiprows=7)

# separate start and end positions
yPosStart, zPosStart, yPosSplat, zPosSplat = [], [], [], []
for i in range(len(datain['Ion N'])):
    if datain['Events'][i] == 1:
        yPosStart.append(datain['Y'][i])
        zPosStart.append(datain['Z'][i])
    if datain['Events'][i] == 16:
        yPosSplat.append(datain['Y'][i])
        zPosSplat.append(datain['Z'][i])
yPosStart = np.array(yPosStart)
yPosSplat = np.array(yPosSplat)
zPosStart = np.array(zPosStart)
zPosSplat = np.array(zPosSplat)

plt.figure("positions")
plt.clf()
plt.plot(yPosStart, zPosStart, 'bo')
plt.plot(yPosSplat, zPosSplat, 'ro')


plt.figure('mean steering')
plt.clf()
plt.plot(yPosStart-yPosSplat, zPosStart-zPosSplat, 'bo')