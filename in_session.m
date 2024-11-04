% Load default contrast table
sub_id = 'COGNAP021';
x = load('contrast_table.mat');

% Choose which of contrastes to use
base_contrast = x.contrast.T1;

% Inside subject loop
local_contrast = base_contrast;
for i = 0:1
  onset_file = sprintf('/mnt/Data/fMRI_data/Design_matrix/ses-T%d/sub-%s_miniblock_onset_norest_pmod_ses-T%d.mat', ...
                       i, sub_id, i);
  onsets = load(onset_file);

  for icol = 1:numel(onsets.names)
    % removing nan at the end
    if numel(onsets.durations{icol}) == 1 && onsets.durations{icol} == 0    
        % At least one nan found
        col_name = onsets.names{icol};
        fprintf('%s: T%d: %s contains no data\n', sub_id, i, col_name);
        res = regexp(col_name, '_nan');
        if ~isempty(res)
            continue
        end
        % getting affected columns
        col_name = sprintf('%s_T%d_mod', col_name, i);
        fprintf('%s: T%d: Removing column %s\n', sub_id, i, col_name);
        local_contrast.(col_name) = [];
    end
  end
end

fprintf('%s: Remaining columns: %d\n', sub_id,...
        size(local_contrast.Properties.VariableNames, 2));

% inside session loop, before running batch
% You can probably use the loop below to generate the majority of the batch
% I can't write it, as I don't have a batch that you use (and I have no idea how to generate it)
for row = 1:size(local_contrast, 1)
  % how to get row name, e.g. T0-T1 SS5
  local_contrast.Properties.RowNames{row}
  % how to get coresponding weights
  table2array(local_contrast(row, :))
end
