function Loop_contrasts(root_pth, onsets_path, base_table)
    % root_path: path to the collection of SPM files 
    % Onsets_path: path to the dataset with onsets, e.g.
    % /mnt/Data/fMRI_data/Design_matrix/
    %
    % base_table: loaded structure with generated tables e.g.
    % contrasts = load('contrast_table.mat');
    % base_table = conrasts.contrast

    subject_list = dir(root_pth); % List with path to BIDS *and* '.', '..'
    subject_list = regexpi({subject_list.name},'sub-COGNAP[0-9]{3}','match'); 
    subject_list = [subject_list{:}]; % Keep only non-empty entries 

    % This should load template batch
    template_job;

    for isub = 1:size(subject_list,2)
        sub = subject_list{isub};
        fprintf('##################################################\n');
        fprintf('Subject %s (%d/%d)\n', subject_list{isub}, isub, size(subject_list,2));
        fprintf('##################################################\n');
        sub_pth = fullfile(root_pth, subject_list{isub});
        flist = struct([]);

        SPM_file = fullfile(sub_pth, 'SPM.mat');
        if ~exist(SPM_file)
            fprintf('No SPM file for this subject');
            continue;
        end
        load(SPM_file);
        exp_cols = numel(SPM.xX.name);


        matlabbatch = template_batch;
        matlabbatch{1}.spm.stats.con.spmmat = {SPM_file};
        matlabbatch{1}.spm.stats.con.consess = {};

        table_names = fieldnames(base_table);
        for i = 1:numel(table_names)
            fprintf('Generating table for %s\n', table_names{i})
            local_contrast = cleanup_table(subject_list{isub},...
                                           base_table.(table_names{i}), onsets_path);
            if size(local_contrast, 2) ~= exp_cols
              warning('Expecting %d columns, got %d', ...
                      exp_cols, size(local_contrast, 2));
            end
            for row = 1:size(local_contrast, 1)
              % how to get row name, e.g. T0-T1 SS5
              a.tcon.name = sprintf('%s_%s', ...
                                    local_contrast.Properties.RowNames{row},...
                                    table_names{i});
              % how to get coresponding weights
              a.tcon.weights = table2array(local_contrast(row, :));
              a.tcon.sessrep = 'none';
              matlabbatch{1}.spm.stats.con.consess{end + 1} = a;
            end
            save(['contrast_', sub, '_', table_names{i}], 'local_contrast');
        end
        save(['batch_', sub], 'matlabbatch');   
     
    end
end


function local_contrast = cleanup_table(sub_id, base_table, onsets_path)
  % sub_id: id of the subject
  % default table (without any dropped columns)
  % onsest_path: path to the directory containing onsets of all subject
  local_contrast = base_table;

  % Loop over sessions
  for s = 0:1
    session = sprintf('T%d', s);
    onset_file = sprintf('%s_miniblock_onset_norest_pmod_ses-%s.mat', ...
                         sub_id, session);
    onset_file = fullfile(onsets_path, ['ses-', session], onset_file);
    onsets = load(onset_file);

    for icol = 1:numel(onsets.names)
      % Checking if column has data
      if numel(onsets.durations{icol}) == 1 && onsets.durations{icol} == 0    
          % No data in column
          col_name = onsets.names{icol};
          fprintf('%s: %s: %s contains no data\n', sub_id, session, col_name);
          % Generating column to remove
          col_name = sprintf('%s_%s_mod', col_name, session);
          % Checking if column to remove exists
          if any(ismember(local_contrast.Properties.VariableNames, col_name))
              % Removing corresponding modified column
              fprintf('%s: %s: Removing column %s\n', sub_id, session, col_name);
              local_contrast.(col_name) = [];
          end
      end
    end
  end

  fprintf('%s: Remaining columns: %d\n', sub_id,...
          size(local_contrast.Properties.VariableNames, 2));

end 
