# This script will get the spot size from the simulated data files and plot as a function of energy and cone size

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os

os.chdir('E:\\OneDrive - TRIUMF\\Projects\\SIMION\\SIMION-Examples\\EinzelLens\\IonStartSweep\\data')

def dist(x, xbar):
    return x - xbar
    
# create a dataframe for the processed data
data = []
for f in os.listdir():
    rundata = pd.read_csv(f, delimiter=',', skiprows=1)
    if rundata.shape[0] == 0:
       data.append([int(f.split('.')[0].split('_')[2]), int(f.split('.')[0].split('_')[4]), 500, 0])
       continue 
    xdist = rundata[rundata.keys()[0]].apply(dist,args=[np.mean(rundata[rundata.keys()[0]])])
    ydist = rundata[rundata.keys()[1]].apply(dist,args=[np.mean(rundata[rundata.keys()[1]])])
    data.append([int(f.split('.')[0].split('_')[2]), int(f.split('.')[0].split('_')[4]), np.sqrt(rundata.max()[rundata.keys()[0]]**2 + rundata.max()[rundata.keys()[1]]**2), rundata.shape[0]/200.])
    
data = pd.DataFrame(data, columns=['ke','ca','r', 'eff'])


# plot the data
plt.figure('cone angle')
for i in data.ke.unique():
    pdata = data[data.eff != 0]
    plt.plot(pdata[pdata.ke == i].ca, pdata[pdata.ke ==i].r, '-o', label = 'KE = '+str(i)+'eV')
plt.ylabel('Beam Radius (mm')
plt.xlabel('Cone half angle (degrees)')
plt.legend()

plt.figure('kinetic energy')
for i in data.ca.unique():
    pdata = data[data.eff != 0]
    plt.plot(pdata[pdata.ca == i].ke, pdata[pdata.ca ==i].r, '-o', label = 'Cone Angle = '+str(i)+'deg')
plt.ylabel('Beam Radius (mm')
plt.xlabel('Initial Kinetic Energy (eV)')
plt.legend()

plt.figure('phase space')
R = np.array(data.r).reshape(len(data.ke.unique()),len(data.ca.unique()))
plt.imshow(R, aspect=len(data.ca.unique())/len(data.ke.unique()))
ax = plt.gca()
ax.set_xticks(np.arange(len(data.ca.unique())),labels=data.ca.unique())
ax.set_yticks(np.arange(len(data.ke.unique())),labels=data.ke.unique())
plt.xlabel('Cone half angle (degrees)')
plt.ylabel('Initial Kinetic Energy (eV)')
plt.colorbar(label='Beam Radius (mm)')
plt.clim(0,1.1*np.amax(data[data.eff != 0].r))


plt.figure('efficiency')
EFF = np.array(data.eff).reshape(len(data.ke.unique()),len(data.ca.unique()))
plt.imshow(EFF, aspect=len(data.ca.unique())/len(data.ke.unique()))
ax = plt.gca()
ax.set_xticks(np.arange(len(data.ca.unique())),labels=data.ca.unique())
ax.set_yticks(np.arange(len(data.ke.unique())),labels=data.ke.unique())
plt.xlabel('Cone half angle (degrees)')
plt.ylabel('Initial Kinetic Energy (eV)')
plt.colorbar(label='Beam Radius (mm)')
plt.clim(0,1.1*np.amax(data[data.eff != 0].eff))
plt.show()