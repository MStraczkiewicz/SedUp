# SedUp
A Matlab script for determining body posture (sedentary vs. standing) using wrist-worn accelerometers

Process a raw accelerometry signal collected using wrist-worn wearable 
device into sedentary and standing indicator.

The method used in this script is called SedUp, short for "sedentary and 
upright body posture classification method". SedUp determines body 
posture using the raw measurement of acceleration transformed into two 
statistical metrics, i.e., median acceleration and median of standard 
deviation of acceleration, and a logistic regression.

Detailed method description was published in:
M. Straczkiewicz, N.W. Glynn, V. Zipunnikov, J. Harezlak, Fast and robust 
algorithm for detecting body posture using wrist-worn accelerometer,
Journal for the Measurement of Physical Behaviour, 2020.

***When used in research study, please cite the provided reference.***

Inputs:
x ~       one dimensional vector of raw acceleration signal collected 
          at the axis parallel to forearm (assuring that x ~= 1 when 
          device is facing the ground), provided in gravitational units
          (g's)
fs ~      sampling frequency of data collection (in Hz, e.g. 100)
option ~  select optimal window size (1: window of 60s, 2: window of 90s)

Output:
standing ~ binary indicator of sitting/lying (0) and standing (1) body 
          postures

Script author:
Marcin Straczkiewicz, PhD
mstraczkiewicz@hsph.harvard.edu; mstraczkiewicz@gmail.com

Last modification: 7/20/2020
