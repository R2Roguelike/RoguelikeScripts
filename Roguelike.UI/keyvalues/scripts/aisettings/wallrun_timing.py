import os
import numpy as np
from functools import lru_cache

frametime = 1.0 / 60.0
def friction(vec, frametime):
    # vec(1-4*frametime)
    return vec - (4 * vec * frametime)

@lru_cache(maxsize=None)
def frictionOverTime(vec, time):
    result = vec
    frames = 0
    while (time > 0):
        time -= frametime
        result = friction(result)
        frames += 1
    print(frames)
    return result

@lru_cache(maxsize=None)
def wallkickWindow(vec, frametime):
    curVec = vec
    frames = 0
    velocityFrames = []
    while ((wallkick(curVec)) > vec):
        velocityFrames.append(wallkick(curVec))
        curVec = friction(curVec, frametime)
        frames += 1
    return frames * frametime, velocityFrames

def wallkick(speed):
    awayFromWall = 205
    forward = 75 + speed
    return np.sqrt(forward * forward + awayFromWall * awayFromWall)

# x(n) = x(n-1) - 4(x(n-1) / 60)
# x()
startSpeed = 120 * 10.936
for i in range(30, 145):
    time, frames = wallkickWindow(startSpeed, 1.0 / i)
    time *= 1000
    print(str(i) + "FPS: " + "{:0.2f}".format(time) + "ms, " + str(frames))