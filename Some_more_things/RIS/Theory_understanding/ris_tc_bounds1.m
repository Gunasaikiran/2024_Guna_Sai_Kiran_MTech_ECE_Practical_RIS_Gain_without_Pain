function out = ris_tc_bounds1(params)
% ris_tc_bounds1  Compute Hoeffding/CLT Tc bounds and optional Monte Carlo check.
% Usage:
%   out = ris_tc_bounds1(params)
% where params is a struct with fields:
%   Ts       - slots per RIS block (positive scalar)
%   M        - number of RIS states (positive integer)
%   eps      - tolerance epsilon (positive scalar)
%   eta      - confidence parameter (0<eta<1)
%   Pm       - optional vector of length M with probabilities (sums to 1)
%   doSim    - optional logical (default false)
%   numSim   - optional number of Monte Carlo runs (default 5000)
%   maxBlocksForSim - optional cap for Bsim (default 2000)

% --- Input checks and defaults ---
if ~isfield(params,'Ts') || ~isfield(params,'M') || ~isfield(params,'eps') || ~isfield(params,'eta')
    error('params must contain fields Ts, M, eps, eta.');
end

Ts = params.Ts;
M  = params.M;
eps = params.eps;
eta = params.eta;

if isfield(params,'Pm')
    Pm = params.Pm;
else
    Pm = [];
end
if isfield(params,'doSim')
    doSim = params.doSim;
else
    doSim = false;
end
if isfield(params,'numSim')
    numSim = params.numSim;
else
    numSim = 5000;
end
if isfield(params,'maxBlocksForSim')
    maxBlocksForSim = params.maxBlocksForSim;
else
    maxBlocksForSim = 2000;
end

% validate basic values
if Ts <= 0 || eps <= 0 || eta <= 0 || eta >= 1
    error('Ts, eps must be >0 and 0 < eta < 1.');
end
if M < 1 || floor(M)~=M
    error('M must be a positive integer.');
end
if ~isempty(Pm)
    if numel(Pm) ~= M
        error('Pm must have length M.');
    end
    if any(Pm < 0) || abs(sum(Pm)-1) > 1e-8
        error('Pm must be a probability vector summing to 1.');
    end
end

% --- Hoeffding + union bound (distribution-free) ---
B_hoeff = (1/(2*eps^2)) * log( (2*M)/eta );
Tc_hoeff = Ts * ceil(B_hoeff);

% --- CLT approximate bound (worst-case Pm=0.5) ---
B_clt_worst = 0.25 / (eps^2);
Tc_clt_worst = Ts * ceil(B_clt_worst);

% --- CLT using provided Pm (if available) ---
if isempty(Pm)
    B_clt_spec = NaN;
    Tc_clt_spec = NaN;
else
    Pm = Pm(:)';  % row
    alpha = eta / (2*M);
    % compute z quantile using the inverse normal CDF
    z = sqrt(2) * erfinv(2*(1-alpha)-1); % equivalent to norminv(1-alpha)
    var_max = max(Pm .* (1 - Pm));
    B_clt_spec = (var_max * z^2) / (eps^2);
    Tc_clt_spec = Ts * ceil(B_clt_spec);
end

% Prepare output
out.Ts = Ts;
out.M = M;
out.eps = eps;
out.eta = eta;
out.B_hoeff = B_hoeff;
out.Tc_hoeff = Tc_hoeff;
out.B_clt_worst = B_clt_worst;
out.Tc_clt_worst = Tc_clt_worst;
out.B_clt_spec = B_clt_spec;
out.Tc_clt_spec = Tc_clt_spec;

% --- Optional Monte Carlo simulation ---
if doSim
    if isnan(B_clt_spec)
        B_candidate = B_hoeff;
    else
        B_candidate = max(B_hoeff, B_clt_spec);
    end
    Bsim = min(maxBlocksForSim, ceil(B_candidate));
    if Bsim < 1, Bsim = 1; end

    if isempty(Pm)
        Pm = ones(1,M)/M;
    else
        Pm = Pm(:)';
    end

    successCount = 0;
    rng(0); % reproducible
    for s = 1:numSim
        % requires Statistics Toolbox for mnrnd; if not available, use custom draw:
        try
            counts = mnrnd(Bsim, Pm);
        catch
            % fallback multinomial sampler:
            counts = multinomial_sample(Bsim, Pm);
        end
        Fm = counts / Bsim;
        if all(abs(Fm - Pm) <= eps)
            successCount = successCount + 1;
        end
    end
    empiricalProb = successCount / numSim;

    out.sim.Bsim = Bsim;
    out.sim.numSim = numSim;
    out.sim.empiricalProb = empiricalProb;
    out.sim.Pm = Pm;
end

% Print summary
fprintf('--- RIS Tc bounds summary ---\n');
fprintf('Ts = %d slots, M = %d, eps = %.4f, eta = %.4f\n', Ts, M, eps, eta);
fprintf('Hoeffding+union: B >= %.2f -> Tc >= %d slots\n', B_hoeff, Tc_hoeff);
fprintf('CLT worst-case:  B >= %.2f -> Tc >= %d slots\n', B_clt_worst, Tc_clt_worst);
if ~isnan(B_clt_spec)
    fprintf('CLT (given Pm):  B >= %.2f -> Tc >= %d slots\n', B_clt_spec, Tc_clt_spec);
end
if doSim
    fprintf('Monte Carlo: Bsim=%d, Pr(|Fm-Pm|<=eps)=%.4f (numSim=%d)\n', ...
            out.sim.Bsim, out.sim.empiricalProb, out.sim.numSim);
end

end

%% --- Helper: fallback multinomial sampler (if mnrnd unavailable) ---
function counts = multinomial_sample(B, p)
% Simple multinomial sampler using cumulative inversion
edges = [0 cumsum(p)];
r = rand(1,B);
counts = zeros(1,length(p));
for i = 1:length(p)
    counts(i) = sum(r > edges(i) & r <= edges(i+1));
end
end
