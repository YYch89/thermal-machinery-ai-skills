function audit = audit_gt_maps(dataRoot)
%AUDIT_GT_MAPS Inspect available map files and planned wrapper choices.
%
% This public example uses a synthetic compressor map. It does not read
% external map files, train neural networks, save files, or modify assets.

if nargin < 1 || isempty(dataRoot)
    dataRoot = fileparts(fileparts(fileparts(mfilename('fullpath'))));
end

GT = build_gt_model_data();

audit = struct();
audit.dataRoot = dataRoot;
audit.compressor = audit_compressor_maps(dataRoot, GT);
audit.turbine = audit_turbine_maps(dataRoot, GT);
audit.summary = build_summary(audit);
end

function compressor = audit_compressor_maps(dataRoot, GT)
compressor = struct();
compressor.primary = GT.mapScale.compressor.primary;
compressor.fallback = GT.mapScale.compressor.fallback;
compressor.interface = 'inputs: pi_c_model,N_GG_rel; outputs: W_air,eta_c,map_valid';

compressor.files.xpi = 'synthetic_public_compressor_map';
compressor.files.localMassFlow = '';
compressor.files.localEfficiency = '';
compressor.files.localHighSpeedWorkbook = '';

compressor.xpi = synthetic_xpi_info();
compressor.localMassFlow = empty_map_info();
compressor.localEfficiency = empty_map_info();
compressor.localHighSpeedWorkbook = struct('file', '', 'exists', false, ...
    'numericSize', [0 0], 'numericMin', NaN, 'numericMax', NaN);

compressor.scaling = GT.mapScale.compressor;
compressor.design.pi_map = 1 + (GT.req.pi_c_nominal - 1)/ ...
    GT.mapScale.compressor.local_s_pi;
compressor.design.N_rel = 1;
compressor.design.W_map_rel = GT.mapScale.compressor.local_W_map_dp;
compressor.design.W_air_kgps = GT.design.state.W_air_kgps;

compressor.design.within_xpi_range = in_range(compressor.design.pi_map, ...
    compressor.xpi.u_col_min(1), compressor.xpi.u_col_max(1)) && ...
    in_range(compressor.design.N_rel, ...
    compressor.xpi.u_col_min(2), compressor.xpi.u_col_max(2));

compressor.design.efficiency_map_can_use_design_flow = false;
compressor.efficiency_source = 'constant_fallback_until_efficiency_map_is_rebased';

compressor.map_valid_at_design = compressor.design.within_xpi_range;
end

function turbine = audit_turbine_maps(dataRoot, GT)
turbine = struct();
turbine.primary = GT.mapScale.turbine.primary;
turbine.fallback = 'same_as_primary_until_local_turbine_map_is_audited';
turbine.interface = 'inputs: PR_t,P_in,T_in; outputs: W_t,eta_t,map_valid';
turbine.K_TG = GT.mapScale.turbine.K_TG;
turbine.K_PT = GT.mapScale.turbine.K_PT;
turbine.localXlsxCandidateCount = 0;
turbine.replacement_status = 'not_included_public_example';
turbine.replacement_blocker = ...
    'local turbine PR, corrected-flow, relative-speed, and efficiency meanings must be confirmed';
turbine.map_valid_at_design = turbine.K_TG > 0 && turbine.K_PT > 0;
end

function summary = build_summary(audit)
summary = struct();
summary.compressor_ready_for_wrapper = audit.compressor.map_valid_at_design;
summary.compressor_efficiency_uses_fallback = ...
    strcmp(audit.compressor.efficiency_source, ...
    'constant_fallback_until_efficiency_map_is_rebased');
summary.turbine_uses_stodola = strcmp(audit.turbine.primary, 'stodola_flugel');
summary.ready_for_steady_map_rated = summary.compressor_ready_for_wrapper && ...
    audit.turbine.map_valid_at_design;
summary.model_level = 'exploratory_reduced';
end

function info = synthetic_xpi_info()
piValues = linspace(3.0, 10.5, 9)';
NValues = linspace(0.7, 1.1, 5)';
[PI, NN] = ndgrid(piValues, NValues);
W = zeros(size(PI));
for k = 1:numel(PI)
    map = evaluate_compressor_xpi_map('synthetic_public_compressor_map', ...
        PI(k), NN(k));
    W(k) = map.W_map_rel;
end

info = struct();
info.file = 'synthetic_public_compressor_map';
info.exists = true;
info.variables = {'synthetic_public_formula'};
info.u_size = [numel(PI) 2];
info.u_col_min = [min(PI(:)) min(NN(:))];
info.u_col_max = [max(PI(:)) max(NN(:))];
info.mz_size = size(W);
info.mz_min = min(W(:));
info.mz_max = max(W(:));
info.D1 = NaN;
info.D2 = NaN;
info.has_network = false;
end

function info = audit_u_mz_file(pathValue)
info = empty_map_info();
info.file = pathValue;
info.exists = isfile(pathValue);
if ~info.exists
    return;
end

S = load(pathValue);
info.variables = fieldnames(S);
if isfield(S, 'u')
    u = S.u;
    info.u_size = size(u);
    info.u_col_min = min(u, [], 1);
    info.u_col_max = max(u, [], 1);
end
if isfield(S, 'mz')
    mz = S.mz;
    info.mz_size = size(mz);
    info.mz_min = min(mz(:));
    info.mz_max = max(mz(:));
end
if isfield(S, 'D1')
    info.D1 = S.D1;
end
if isfield(S, 'D2')
    info.D2 = S.D2;
end
info.has_network = any(cellfun(@(name) is_network_object(S.(name)), fieldnames(S)));
end

function info = audit_workbook_preview(pathValue)
info = struct('file', pathValue, 'exists', isfile(pathValue), ...
    'numericSize', [0 0], 'numericMin', NaN, 'numericMax', NaN);
if ~info.exists
    return;
end
try
    M = readmatrix(pathValue);
    info.numericSize = size(M);
    numericValues = M(isfinite(M));
    if ~isempty(numericValues)
        info.numericMin = min(numericValues);
        info.numericMax = max(numericValues);
    end
catch
    info.read_error = true;
end
end

function info = empty_map_info()
info = struct();
info.file = '';
info.exists = false;
info.variables = {};
info.u_size = [0 0];
info.u_col_min = [NaN NaN];
info.u_col_max = [NaN NaN];
info.mz_size = [0 0];
info.mz_min = NaN;
info.mz_max = NaN;
info.D1 = NaN;
info.D2 = NaN;
info.has_network = false;
end

function tf = is_network_object(value)
tf = strcmp(class(value), 'network');
end

function tf = in_range(value, lower, upper)
tol = 1e-10*max(1, max(abs([value lower upper])));
tf = isfinite(value) && isfinite(lower) && isfinite(upper) && ...
    value >= lower - tol && value <= upper + tol;
end

function pathValue = find_first_file(rootFolder, pattern)
matches = dir(fullfile(rootFolder, '**', pattern));
if isempty(matches)
    pathValue = '';
else
    pathValue = fullfile(matches(1).folder, matches(1).name);
end
end

function pathValue = find_named_file(rootFolder, pattern, requiredText)
matches = dir(fullfile(rootFolder, '**', pattern));
if isempty(matches)
    pathValue = '';
    return;
end

names = lower({matches.name});
idx = find(contains(names, lower(requiredText)), 1, 'first');
if isempty(idx)
    idx = 1;
end
pathValue = fullfile(matches(idx).folder, matches(idx).name);
end

function n = count_files(rootFolder, pattern)
matches = dir(fullfile(rootFolder, '**', pattern));
n = numel(matches);
end
