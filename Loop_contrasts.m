function Loop_contrasts(root_pth, onsets_path, intable)
    % root_path: path to the collection of SPM files 
    % Onsets_path: path to the dataset with onsets, e.g.
    % /mnt/Data/fMRI_data/Design_matrix/
    %
    % intable: path to xml table with defined contrasts

    subject_list = dir(root_pth); % List with path to BIDS *and* '.', '..'
    subject_list = regexpi({subject_list.name},'^sub-COGNAP[0-9]{3}','match'); 
    subject_list = [subject_list{:}]; % Keep only non-empty entries 

    %sheets_list = {'T0', 'T1', 'T1_T0'};
    if exist('sheetnames', 'builtin')
      sheets_list = sheetnames(intable);
    else
      [~, sheets_list] = xlsfinfo(intable);
    end
    % sheets_list = {'T0'};
    % intable = 'contrasts_sessionbysession.xlsx';
    base_table = struct();
    for is = 1:numel(sheets_list)
      base_table(is).T = readtable(intable, ...
                                   'Sheet', sheets_list{is}, ...
                                   'readrownames', true);
      base_table(is).name = sheets_list{is};
    end

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

        spm_names = SPM.xX.name;
        tab_names = {};
        for i = 1:numel(spm_names)
          tab_names{end + 1} = gen_colname(spm_names{i});
        end

        matlabbatch = template_batch;
        matlabbatch{1}.spm.stats.con.spmmat = {SPM_file};
        matlabbatch{1}.spm.stats.con.consess = {};

        table_names = fieldnames(base_table);
        for i = 1:numel(base_table)
            fprintf('Generating table for %s\n', base_table(i).name);
            row_names = base_table(i).T.Properties.RowNames;
            cols = base_table(i).T.Properties.VariableNames;
            local_contrast = array2table(zeros(numel(row_names),...
                                               numel(tab_names)...
                                               )...
                                         );
            local_contrast.Properties.VariableNames = tab_names;
            local_contrast.Properties.RowNames = row_names;

            for icol = 1:numel(cols)
              col_name = cols{icol};
              if any(ismember(local_contrast.Properties.VariableNames, col_name))
                if nnz(local_contrast.(col_name))
                  error('Trying to update non-empty column %s (%s)',...
                        col_name, num2xlcol(icol));
                end
                local_contrast.(col_name) = base_table(i).T.(col_name);
              else
                error('Trying to update missing column %s (%s)',...
                      col_name, num2xlcol(icol));
              end
            end
            fprintf('Updated %d columns\n', numel(cols))

            for row = 1:size(local_contrast, 1)
              % how to get row name, e.g. T0-T1 SS5
              a.tcon.name = sprintf('%s_%s', ...
                                    local_contrast.Properties.RowNames{row},...
                                    base_table(i).name);
              % how to get coresponding weights
              a.tcon.weights = table2array(local_contrast(row, :));
              a.tcon.sessrep = 'none';
              matlabbatch{1}.spm.stats.con.consess{end + 1} = a;
            end
            save(['contrast_', sub, '_', base_table(i).name], 'local_contrast');
        end
        save(['batch_', sub], 'matlabbatch');   
     
    end
end

function res = num2xlcol(val)
  letters = 26;
  offset = 65;

  res = '';
  if val == 0
    res = 'A';
    return
  end

  while val > 0
    letter = mod(val, letters); 
    val = (val - letter) / 26;
    res = [char(offset + letter) res];
  end
end
