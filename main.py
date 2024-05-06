import cv2
from functools import partial

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

L = 2*np.pi
T = 500
alpha = 2.0
dx = 1
dt = (dx**2)/(4*alpha)
gamma = (alpha * dt / dx**2)

N = 100
u = cv2.imread("smiley.jpg", 0)
u = cv2.resize(u, (100, 100)) 
u = u.astype(np.int64)
u = np.abs(255 - np.flip(u, axis=0))

u[:, 0] = -0
u[:, -1] = -0
u[0, :] = -0
u[-1, :] = -0

fig, ax = plt.subplots()

def update(frame):
  global u
  plt.clf()
  u_new = np.copy(u)
  for i in range(1, N-1):
    for j in range(1, N-1):
      u_new[i, j] = gamma * (u[i+1, j] + 
                         u[i-1, j] + 
                         u[i, j+1] +
                         u[i, j-1] -
                         4*u[i, j]) + u[i, j]

  u = u_new
  plt.xlabel("x")
  plt.ylabel("y")
  plt.title(f"Frame: {frame}")
  plt.pcolormesh(u, cmap=plt.cm.viridis, vmin=0, vmax=100)
  plt.colorbar()

animation = FuncAnimation(
  fig,
  update,
  interval=5,
  frames=T,
  repeat=True
)

plt.show()
