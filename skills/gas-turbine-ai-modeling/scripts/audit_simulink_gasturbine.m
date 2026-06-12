function report = audit_simulink_gasturbine(modelName, varargin)
%AUDIT_SIMULINK_GASTURBINE Collect executable evidence from a gas turbine Simulink model.
%
% report = audit_simulink_gasturbine("modelName")
% report = audit_simulink_gasturbine("modelName", "OutputDir", "audit")
%
% The script is intentionally read-only for the model. It loads the model if
% needed, inspects block structure and parameters, and writes audit artifacts
% that an AI agent or engineer can review before editing.

parser = inputParser;
parser.addRequired('modelName', @(x) ischar(x) || isstring(x));
parser.addParameter('OutputDir', fullfile(pwd, 'gas_turbine_model_audit'), @(x) ischar(x) || isstring(x));
parser.addParameter('LoadModel', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('WriteFiles', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('LookUnderMasks', 'all', @(x) ischar(x) || isstring(x));
parser.addParameter('FollowLinks', 'on', @(x) ischar(x) || isstring(x));
parser.parse(modelName, varargin{:});

modelName = char(parser.Results.modelName);
outputDir = char(parser.Results.OutputDir);
lookUnderMasks = char(parser.Results.LookUnderMasks);
followLinks = char(parser.Results.FollowLinks);

if endsWith(lower(modelName), '.slx') || endsWith(lower(modelName), '.mdl')
    modelPath = modelName;
    [~, modelNameOnly] = fileparts(modelPath);
else
    modelPath = '';
    modelNameOnly = modelName;
end

if parser.Results.LoadModel
    if ~bdIsLoaded(modelNameOnly)
        if ~isempty(modelPath)
            load_system(modelPath);
        else
            load_system(modelNameOnly);
        end
    end
end

modelName = modelNameOnly;

report = struct();
report.generatedAt = char(datetime('now', 'Format', 'yyyyMMdd''T''HHmmss'));
report.model = modelName;
report.modelFile = safeGetParam(modelName, 'FileName');
report.configuration = collectConfiguration(modelName);
report.subsystems = collectBlocks(modelName, {'SubSystem'}, lookUnderMasks, followLinks);
report.dynamicStateBlocks = collectStateBlocks(modelName, lookUnderMasks, followLinks);
report.functionBlocks = collectFunctionBlocks(modelName, lookUnderMasks, followLinks);
report.lookupBlocks = collectLookupBlocks(modelName, lookUnderMasks, followLinks);
report.signalRoutingBlocks = collectBlocks(modelName, {'Goto','From','DataStoreMemory','DataStoreRead','DataStoreWrite','BusCreator','BusSelector','Mux','Demux'}, lookUnderMasks, followLinks);
report.constantsAndGains = collectBlocks(modelName, {'Constant','Gain'}, lookUnderMasks, followLinks);
report.namedCandidates = collectNamedCandidates(modelName, lookUnderMasks, followLinks);
report.workspaceVariables = collectWorkspaceVariables(modelName);
report.summary = makeSummary(report);

if parser.Results.WriteFiles
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    writeAuditFiles(report, outputDir);
end
end

function config = collectConfiguration(modelName)
config = struct();
fields = {'Solver','SolverType','StartTime','StopTime','FixedStep','MaxStep','MinStep', ...
    'RelTol','AbsTol','SimulationMode','SignalLogging','SignalLoggingName', ...
    'SaveOutput','SaveTime','ReturnWorkspaceOutputs'};
for k = 1:numel(fields)
    config.(fields{k}) = safeGetParam(modelName, fields{k});
end
end

function rows = collectStateBlocks(modelName, lookUnderMasks, followLinks)
types = {'Memory','UnitDelay','Delay','Integrator','DiscreteIntegrator', ...
    'TransferFcn','DiscreteTransferFcn','TransportDelay','StateSpace', ...
    'DiscreteStateSpace','ZeroOrderHold'};
rows = collectBlocks(modelName, types, lookUnderMasks, followLinks);
end

function rows = collectFunctionBlocks(modelName, lookUnderMasks, followLinks)
rows = collectBlocks(modelName, {'Fcn','MATLABFcn','S-Function','SubSystem'}, lookUnderMasks, followLinks);
paths = {rows.Path};
keep = false(size(paths));
for k = 1:numel(paths)
    blockType = safeGetParam(paths{k}, 'BlockType');
    maskType = safeGetParam(paths{k}, 'MaskType');
    sfBlockType = safeGetParam(paths{k}, 'SFBlockType');
    if any(strcmp(blockType, {'Fcn','MATLABFcn','S-Function'})) || ...
            containsIgnoreCase(maskType, 'matlab function') || ...
            containsIgnoreCase(sfBlockType, 'matlab function')
        keep(k) = true;
    end
end
rows = rows(keep);
end

function rows = collectLookupBlocks(modelName, lookUnderMasks, followLinks)
allRows = collectAllBlocks(modelName, lookUnderMasks, followLinks);
keep = false(size(allRows));
for k = 1:numel(allRows)
    blockType = safeGetParam(allRows(k).Path, 'BlockType');
    maskType = safeGetParam(allRows(k).Path, 'MaskType');
    name = safeGetParam(allRows(k).Path, 'Name');
    if containsIgnoreCase(blockType, 'lookup') || containsIgnoreCase(blockType, 'table') || ...
            containsIgnoreCase(maskType, 'lookup') || containsIgnoreCase(name, 'lookup') || ...
            containsIgnoreCase(name, 'map') || containsIgnoreCase(name, 'characteristic')
        keep(k) = true;
    end
end
rows = allRows(keep);
end

function rows = collectNamedCandidates(modelName, lookUnderMasks, followLinks)
allRows = collectAllBlocks(modelName, lookUnderMasks, followLinks);
keywords = {'compressor','comp','lpc','hpc','yaqiji','压气机', ...
    'turbine','hpt','lpt','pt','toupin','涡轮', ...
    'combustor','burner','ranshao','燃烧', ...
    'volume','plenum','chamber','pressure','rongqiang','容腔','容积', ...
    'rotor','shaft','spool','zhuanzi','转子','轴', ...
    'fuel','load','map','characteristic','特性'};
keep = false(size(allRows));
for k = 1:numel(allRows)
    haystack = lower([safeGetParam(allRows(k).Path, 'Name') ' ' allRows(k).Path]);
    for j = 1:numel(keywords)
        if containsIgnoreCase(haystack, keywords{j})
            keep(k) = true;
            break;
        end
    end
end
rows = allRows(keep);
end

function rows = collectBlocks(modelName, blockTypes, lookUnderMasks, followLinks)
rows = struct('Path', {}, 'Name', {}, 'BlockType', {}, 'MaskType', {}, ...
    'SampleTime', {}, 'InitialCondition', {}, 'InitialOutput', {}, ...
    'Value', {}, 'Gain', {}, 'Expression', {}, 'Numerator', {}, ...
    'Denominator', {}, 'DelayLength', {}, 'Table', {}, ...
    'Breakpoints', {}, 'GotoTag', {}, 'Commented', {}, 'LinkStatus', {});
for k = 1:numel(blockTypes)
    paths = safeFindSystem(modelName, 'BlockType', blockTypes{k}, lookUnderMasks, followLinks);
    rows = [rows; enrichBlocks(paths(:))]; %#ok<AGROW>
end
rows = uniqueRows(rows);
end

function rows = collectAllBlocks(modelName, lookUnderMasks, followLinks)
paths = safeFindSystem(modelName, '', '', lookUnderMasks, followLinks);
rows = enrichBlocks(paths(:));
end

function rows = enrichBlocks(paths)
template = struct('Path', '', 'Name', '', 'BlockType', '', 'MaskType', '', ...
    'SampleTime', '', 'InitialCondition', '', 'InitialOutput', '', ...
    'Value', '', 'Gain', '', 'Expression', '', 'Numerator', '', ...
    'Denominator', '', 'DelayLength', '', 'Table', '', ...
    'Breakpoints', '', 'GotoTag', '', 'Commented', '', 'LinkStatus', '');
rows = repmat(template, 0, 1);
for k = 1:numel(paths)
    p = char(paths{k});
    row = template;
    row.Path = p;
    row.Name = safeGetParam(p, 'Name');
    row.BlockType = safeGetParam(p, 'BlockType');
    row.MaskType = safeGetParam(p, 'MaskType');
    row.SampleTime = firstNonEmpty({safeGetParam(p, 'SampleTime'), safeGetParam(p, 'CompiledSampleTime')});
    row.InitialCondition = firstNonEmpty({safeGetParam(p, 'InitialCondition'), safeGetParam(p, 'InitialConditionSource'), safeGetParam(p, 'X0')});
    row.InitialOutput = firstNonEmpty({safeGetParam(p, 'InitialOutput'), safeGetParam(p, 'vinit')});
    row.Value = safeGetParam(p, 'Value');
    row.Gain = safeGetParam(p, 'Gain');
    row.Expression = firstNonEmpty({safeGetParam(p, 'Expr'), safeGetParam(p, 'MATLABFcn')});
    row.Numerator = safeGetParam(p, 'Numerator');
    row.Denominator = safeGetParam(p, 'Denominator');
    row.DelayLength = firstNonEmpty({safeGetParam(p, 'DelayLength'), safeGetParam(p, 'DelayLengthSource')});
    row.Table = firstNonEmpty({safeGetParam(p, 'Table'), safeGetParam(p, 'TableData'), safeGetParam(p, 'LookupTableObject')});
    row.Breakpoints = collectBreakpointParams(p);
    row.GotoTag = safeGetParam(p, 'GotoTag');
    row.Commented = safeGetParam(p, 'Commented');
    row.LinkStatus = safeGetParam(p, 'LinkStatus');
    rows(end+1, 1) = row; %#ok<AGROW>
end
end

function rows = uniqueRows(rows)
if isempty(rows)
    return;
end
[~, idx] = unique({rows.Path}, 'stable');
rows = rows(idx);
end

function vars = collectWorkspaceVariables(modelName)
vars = struct('Name', {}, 'Source', {}, 'Users', {});
try
    found = Simulink.findVars(modelName);
    vars = repmat(vars, numel(found), 1);
    for k = 1:numel(found)
        vars(k).Name = char(found(k).Name);
        vars(k).Source = char(found(k).Source);
        try
            vars(k).Users = strjoin(cellstr(found(k).Users), '; ');
        catch
            vars(k).Users = '';
        end
    end
catch err
    vars(1).Name = 'Simulink.findVars failed';
    vars(1).Source = err.message;
    vars(1).Users = '';
end
end

function paths = safeFindSystem(modelName, paramName, paramValue, lookUnderMasks, followLinks)
try
    if isempty(paramName)
        paths = find_system(modelName, 'LookUnderMasks', lookUnderMasks, ...
            'FollowLinks', followLinks, 'Type', 'Block');
    else
        paths = find_system(modelName, 'LookUnderMasks', lookUnderMasks, ...
            'FollowLinks', followLinks, 'Type', 'Block', paramName, paramValue);
    end
catch
    paths = {};
end
paths = cellstr(paths);
end

function value = safeGetParam(path, paramName)
try
    value = get_param(path, paramName);
    value = stringify(value);
catch
    value = '';
end
end

function out = collectBreakpointParams(path)
names = {'BreakpointsForDimension1','BreakpointsForDimension2','BreakpointsForDimension3', ...
    'BreakpointsForDimension4','BreakpointsForDimension5','BreakpointsForDimension6', ...
    'BreakpointsForDimension7','BreakpointsForDimension8','BreakpointsForDimension9', ...
    'BreakpointsSpecification','Breakpoints'};
parts = {};
for k = 1:numel(names)
    value = safeGetParam(path, names{k});
    if ~isempty(value)
        parts{end+1} = [names{k} '=' value]; %#ok<AGROW>
    end
end
out = strjoin(parts, '; ');
end

function text = stringify(value)
if ischar(value)
    text = value;
elseif isstring(value)
    text = char(strjoin(value, ', '));
elseif isnumeric(value) || islogical(value)
    if isempty(value)
        text = '';
    else
        text = mat2str(value);
    end
elseif iscell(value)
    try
        text = strjoin(cellfun(@stringify, value, 'UniformOutput', false), ', ');
    catch
        text = '<cell>';
    end
else
    try
        text = char(value);
    catch
        text = ['<' class(value) '>'];
    end
end
end

function result = firstNonEmpty(values)
result = '';
for k = 1:numel(values)
    if ~isempty(values{k})
        result = values{k};
        return;
    end
end
end

function tf = containsIgnoreCase(text, pattern)
tf = ~isempty(regexpi(char(text), regexptranslate('escape', char(pattern)), 'once'));
end

function summary = makeSummary(report)
summary = struct();
summary.model = report.model;
summary.generatedAt = report.generatedAt;
summary.numSubsystems = numel(report.subsystems);
summary.numDynamicStateBlocks = numel(report.dynamicStateBlocks);
summary.numFunctionBlocks = numel(report.functionBlocks);
summary.numLookupBlocks = numel(report.lookupBlocks);
summary.numRoutingBlocks = numel(report.signalRoutingBlocks);
summary.numNamedCandidates = numel(report.namedCandidates);
summary.notes = { ...
    'Review dynamicStateBlocks for explicit initial conditions and sample times.', ...
    'Review lookupBlocks for map inputs, outputs, breakpoints, and valid-domain logic.', ...
    'Review functionBlocks for hidden plant physics.', ...
    'Review namedCandidates to locate compressor, turbine, volume, rotor, combustor, fuel, load, and map subsystems.', ...
    'This script collects evidence; it does not prove physical correctness.'};
end

function writeAuditFiles(report, outputDir)
writeJson(fullfile(outputDir, [report.model '_audit.json']), report);
writeMarkdown(fullfile(outputDir, [report.model '_audit.md']), report);
writeTable(fullfile(outputDir, [report.model '_dynamic_state_blocks.csv']), report.dynamicStateBlocks);
writeTable(fullfile(outputDir, [report.model '_function_blocks.csv']), report.functionBlocks);
writeTable(fullfile(outputDir, [report.model '_lookup_blocks.csv']), report.lookupBlocks);
writeTable(fullfile(outputDir, [report.model '_signal_routing_blocks.csv']), report.signalRoutingBlocks);
writeTable(fullfile(outputDir, [report.model '_named_candidates.csv']), report.namedCandidates);
writeTable(fullfile(outputDir, [report.model '_workspace_variables.csv']), report.workspaceVariables);
end

function writeJson(path, data)
try
    fid = fopen(path, 'w');
    cleanup = onCleanup(@() fclose(fid));
    fprintf(fid, '%s', jsonencode(data, 'PrettyPrint', true));
catch
    try
        save(strrep(path, '.json', '.mat'), 'data');
    catch
    end
end
end

function writeMarkdown(path, report)
fid = fopen(path, 'w');
cleanup = onCleanup(@() fclose(fid));
fprintf(fid, '# Gas Turbine Simulink Audit\n\n');
fprintf(fid, '| Field | Value |\n| --- | --- |\n');
fprintf(fid, '| Model | `%s` |\n', report.model);
fprintf(fid, '| Generated | `%s` |\n', report.generatedAt);
fprintf(fid, '| Model file | `%s` |\n', report.modelFile);
fprintf(fid, '| Solver | `%s` |\n', safeField(report.configuration, 'Solver'));
fprintf(fid, '| Solver type | `%s` |\n', safeField(report.configuration, 'SolverType'));
fprintf(fid, '| Stop time | `%s` |\n', safeField(report.configuration, 'StopTime'));
fprintf(fid, '| Fixed step | `%s` |\n', safeField(report.configuration, 'FixedStep'));
fprintf(fid, '\n## Counts\n\n');
fprintf(fid, '- Subsystems: %d\n', numel(report.subsystems));
fprintf(fid, '- Dynamic state blocks: %d\n', numel(report.dynamicStateBlocks));
fprintf(fid, '- Function or black-box blocks: %d\n', numel(report.functionBlocks));
fprintf(fid, '- Lookup/map candidate blocks: %d\n', numel(report.lookupBlocks));
fprintf(fid, '- Signal routing blocks: %d\n', numel(report.signalRoutingBlocks));
fprintf(fid, '- Named gas-turbine candidates: %d\n', numel(report.namedCandidates));
fprintf(fid, '\n## Required Human/Agent Review\n\n');
fprintf(fid, '1. Classify compressor, turbine, combustor, volume, rotor, fuel, load, and map subsystems from the named candidates.\n');
fprintf(fid, '2. Confirm every dynamic state block has a physical state meaning, unit, initial value, and validation check.\n');
fprintf(fid, '3. Confirm lookup/map blocks expose input variables, output variables, breakpoints, saturation, and valid-domain logic.\n');
fprintf(fid, '4. Inspect function blocks for hidden plant physics before claiming a component-level Simulink model.\n');
fprintf(fid, '5. If the model fails, trace the first nonphysical pressure, temperature, flow, shaft speed, or map-valid signal upstream from the reported block.\n');
end

function value = safeField(s, name)
if isfield(s, name)
    value = s.(name);
else
    value = '';
end
end

function writeTable(path, rows)
try
    if isempty(rows)
        fid = fopen(path, 'w');
        cleanup = onCleanup(@() fclose(fid));
        fprintf(fid, 'No rows\n');
    else
        writetable(struct2table(rows), path);
    end
catch
    try
        save(strrep(path, '.csv', '.mat'), 'rows');
    catch
    end
end
end
