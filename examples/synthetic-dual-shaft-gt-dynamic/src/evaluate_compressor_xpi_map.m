function map = evaluate_compressor_xpi_map(mapFile, pi_map, N_rel)
%EVALUATE_COMPRESSOR_XPI_MAP Evaluate the public compressor xpi map.
%
% The default public example is self-contained and uses a synthetic
% pressure-ratio/relative-speed map. If a caller supplies a real `.mat` map
% with `u` and `mz`, the same interpolation path can still be exercised.

if nargin < 1 || isempty(mapFile) || strcmp(mapFile, 'synthetic_public_compressor_map')
    map = evaluate_synthetic_public_map(pi_map, N_rel);
    return;
end

persistent cachedFile cachedU cachedMz

if isempty(cachedFile) || ~strcmp(cachedFile, mapFile)
    S = load(mapFile);
    cachedFile = mapFile;
    cachedU = S.u;
    cachedMz = S.mz(:);
end

u = cachedU;
mz = cachedMz;
uMin = min(u, [], 1);
uMax = max(u, [], 1);
valid = in_range(pi_map, uMin(1), uMax(1)) && ...
    in_range(N_rel, uMin(2), uMax(2));

tol = 1e-10*max(1, max(abs([pi_map N_rel u(:)'])));
exactIdx = find(abs(u(:, 1) - pi_map) <= tol & ...
    abs(u(:, 2) - N_rel) <= tol, 1, 'first');

if ~isempty(exactIdx)
    W_map_rel = mz(exactIdx);
    source = 'raw_map_point';
else
    interpolant = scatteredInterpolant(u(:, 1), u(:, 2), mz, ...
        'linear', 'none');
    W_map_rel = interpolant(pi_map, N_rel);
    source = 'linear_scattered_interpolant';
    if ~isfinite(W_map_rel)
        [~, nearestIdx] = min(hypot(u(:, 1) - pi_map, u(:, 2) - N_rel));
        W_map_rel = mz(nearestIdx);
        source = 'nearest_raw_point_outside_interpolant';
        valid = false;
    end
end

map = struct( ...
    'W_map_rel', W_map_rel, ...
    'valid', valid, ...
    'source', source, ...
    'u_col_min', uMin, ...
    'u_col_max', uMax);
end

function map = evaluate_synthetic_public_map(pi_map, N_rel)
pi0 = 8.24751;
W0 = 0.975281;
piMin = 3.0;
piMax = 10.5;
NMin = 0.7;
NMax = 1.1;

pressureShape = 1 - 0.035*((pi_map - pi0)/pi0).^2;
speedShape = 1 + 0.65*(N_rel - 1) - 0.15*(N_rel - 1).^2;
W_map_rel = W0 * pressureShape .* speedShape;
valid = in_range(pi_map, piMin, piMax) && in_range(N_rel, NMin, NMax) && ...
    isfinite(W_map_rel) && W_map_rel > 0;

map = struct( ...
    'W_map_rel', W_map_rel, ...
    'valid', valid, ...
    'source', 'synthetic_public_formula', ...
    'u_col_min', [piMin NMin], ...
    'u_col_max', [piMax NMax]);
end

function tf = in_range(value, lower, upper)
tol = 1e-10*max(1, max(abs([value lower upper])));
tf = isfinite(value) && isfinite(lower) && isfinite(upper) && ...
    value >= lower - tol && value <= upper + tol;
end
