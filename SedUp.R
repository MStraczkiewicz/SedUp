SedUp <- function(x, fs, option) {
  # Process a raw accelerometry signal collected using wrist-worn wearable 
  # device into sedentary and standing indicator.
  #
  # The method used in this script is called SedUp, short for "sedentary and 
  # upright body posture classification method". SedUp determines body 
  # posture using the raw measurement of acceleration transformed into two 
  # statistical metrics, i.e., median acceleration and median of standard 
  # deviation of acceleration, and a logistic regression.
  #
  # Detailed method description was published in:
  # M. Straczkiewicz, N.W. Glynn, V. Zipunnikov, J. Harezlak, Fast and robust 
  # algorithm for detecting body posture using wrist-worn accelerometer,
  # Journal for the Measurement of Physical Behaviour, 2020.
  #
  # ***When used in research study, please cite the provided reference.***
  #    
  # Inputs:
  # x ~       one dimensional vector of raw acceleration signal collected 
  #           at the axis parallel to forearm (assuring that x ~= 1 when 
  #           device is facing the ground), provided in gravitational units
  #           (g's)
  # fs ~      sampling frequency of data collection (in Hz, e.g. 100)
  # option ~  select optimal window size (1: window of 60s, 2: window of 90s)
   
  # Output:
  # standing ~ binary indicator of sitting/lying (0) and standing (1) body 
  #           postures
  #
  # Script author:
  # Marcin Straczkiewicz, PhD
  # mstraczkiewicz@hsph.harvard.edu; mstraczkiewicz@gmail.com
  #
  # Last modification: 5/17/2022
  constant <- 15
  
  # select model of SedUp for different window size
  if (option == 1) {  # 60secs
    coeffs  <- c(-2.390, 2.542, 42.394)
    uni_thr <- 0.362
    nSec    <- 4
  } else if (option == 2)  {  # 90secs
    coeffs  <- c(-2.420, 2.616, 44.083)
    uni_thr <- 0.372
    nSec    <- 6
  }
  
  # trim the measurement to match desired window size
  x <- x[1:(floor(length(x)/fs/constant)*fs*constant)]
  
  # calculate standard deviation
  sdv <- apply(matrix(x, nrow = fs), 2, sd)
  
  # determine windows for metrics
  window1 <- nSec*constant*fs/2
  window2 <- round(nSec*constant/2)

  # allocate memory for metrics and initiate variables
  medacc  <- integer(length(sdv)/constant)
  medsd   <- integer(length(sdv)/constant)
  j1      <- 0
  j2      <- 0
  
  # calculate metrics
  for (i in seq(from = 1, to = length(sdv), by = constant)) {
    j1   <- j1 + 1
    i1_1 <- (i - 1) * fs + 1 - window1
    i1_2 <- (i - 1) * fs + 1 + constant * fs + window1
    b    <- i1_1:i1_2
    medacc[j1] <- median(x[b[b > 0 & b < length(x)]], na.rm = TRUE)

    j2   <- j2 + 1
    i2_1 <- (i - 1) - window2
    i2_2 <- (i - 1) + 1 + constant + window2
    b    <- i2_1:i2_2
    medsd[j2] <- median(sdv[b[b >0 & b < length(sdv)]], na.rm = TRUE)
  }

  # use model parameters over metrics
  logit <- coeffs[1] + coeffs[2]*medacc + coeffs[3]*medsd
  phat <- exp(logit) / (1+exp(logit))
  
  # determine posture
  standing <- matrix(data=NA,nrow=length(phat),ncol=1)
  standing[phat >= uni_thr] <- 1
  standing[phat < uni_thr]  <- 0
  standing <- rep(standing, each=constant*fs)

  return(standing)
}