function standing = SedUp(x, fs, option)
% Process a raw accelerometry signal collected using wrist-worn wearable 
% device into sedentary and standing indicator.
%
% The method used in this script is called SedUp, short for "sedentary and 
% upright body posture classification method". SedUp determines body 
% posture using the raw measurement of acceleration transformed into two 
% statistical metrics, i.e., median acceleration and median of standard 
% deviation of acceleration, and a logistic regression.
%
% Detailed method description was published in:
% M. Straczkiewicz, N.W. Glynn, V. Zipunnikov, J. Harezlak, Fast and robust 
% algorithm for detecting body posture using wrist-worn accelerometer,
% Journal for the Measurement of Physical Behaviour, 2020.
%
% ***When used in research study, please cite the provided reference.***
%
% Inputs:
% x ~       one dimensional vector of raw acceleration signal collected 
%           at the axis parallel to forearm (assuring that x ~= 1 when 
%           device is facing the ground), provided in gravitational units
%           (g's)
% fs ~      sampling frequency of data collection (in Hz, e.g. 100)
% option ~  select optimal window size (1: window of 60s, 2: window of 90s)
% 
% Output:
% standing ~ binary indicator of sitting/lying (0) and standing (1) body 
%           postures
%
% Script author:
% Marcin Straczkiewicz, PhD
% mstraczkiewicz@hsph.harvard.edu; mstraczkiewicz@gmail.com
%
% Last modification: 7/20/2020

% determine a constant window size expressed in seconds
constant = 15;

% select model of SedUp for different window size
if option == 1 % 60secs
    coeffs  = [-2.390; 2.542; 42.394];
    uni_thr = 0.362;
    nSec    = 4;
elseif option == 2 % 90secs
    coeffs  = [-2.420; 2.616; 44.083];
    uni_thr = 0.372;
    nSec    = 6;
end

% trim the measurement to match desired window size
x           = x(1:floor(numel(x)/fs/constant)*fs*constant);

% calculate standard deviation
sdv         = std(reshape(x,[fs length(x)/fs]));
sdv         = sdv(:);

% determine windows for metrics
window1     = nSec*constant*fs/2;
window2     = round(nSec*constant/2);

% allocate memory for metrics
medacc      = zeros(numel(sdv)/constant,1);
medsd       = zeros(numel(sdv)/constant,1);
j1          = 0;
j2          = 0;

% calculate metrics
for i = 1 : constant : numel(sdv)
    j1      = j1 + 1;
    i1_1    = (i-1)*fs+1 - window1;
    i1_2    = (i-1)*fs+1+1*constant*fs + window1;
    b       = i1_1:i1_2; b = b';
    medacc(j1,1) = median(x   (b(b>0&b<length(x   ))), 'omitnan');

    j2      = j2 + 1;
    i2_1    = (i-1)-window2;
    i2_2    = (i-1)+1+constant+window2;
    b       = i2_1:i2_2; b = b';
    medsd(j2,1) = median(sdv(b(b>0&b<length(sdv))), 'omitnan');
end
medsd       = medsd(:);
medacc      = medacc(:);

% use model parameters over metrics
logit       = coeffs(1) + coeffs(2)*medacc + coeffs(3)*medsd;
phat        = exp(logit)./ (1 + exp(logit));

% determine posture
standing                  = nan(size(phat));
standing(phat >= uni_thr) = 1;
standing(phat <  uni_thr) = 0;

standing = repelem(standing, constant*fs);