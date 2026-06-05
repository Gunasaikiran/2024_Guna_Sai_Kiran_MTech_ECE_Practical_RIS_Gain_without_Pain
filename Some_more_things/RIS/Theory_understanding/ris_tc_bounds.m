% run_ris_tc_bounds.m
% Driver script to compute Tc bounds for your RIS system

clear; clc;

% Parameters you requested:
K = 10;       % number of users (not used directly in Tc bound)
M = 5;        % number of RIS states
eps = 0.01;   % epsilon accuracy
eta = 0.01;   % confidence parameter
Ts = 100;     % Ts (slots per RIS block) - change as needed

% Optional: Pm distribution (uniform or custom)
Pm = ones(1, M) / M;

% Pack into parameter struct
params.Ts = Ts;
params.M = M;
params.eps = eps;
params.eta = eta;
params.Pm = Pm;

% Enable Monte-Carlo simulation
params.doSim = true;
params.numSim = 5000;
params.maxBlocksForSim = 35000;

% Call the Tc bound function (must be on the MATLAB path)
out = ris_tc_bounds1(params);

% Display the output struct
disp(out);
