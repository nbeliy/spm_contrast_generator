function tab = f_contrast(spm_names, sessions, include, exclude)
  % Create a F-contrast table based on the list of spm columns
  % and the selection of sessions, and include/exclude strings
  %
  % Example:
  % tab = f_contrast(spm_names, {'T0'}, {'_cor_'}, {'_mod_'})
  % will generate a table with 0 everywhere except for the session T0
  % correct awnsers (include = {'_cor_'}) and not modified (exclude={'_mod_'})
  %
  % Parameters:
  %   spm_names: cell of strings, same as SPM.xX.name
  %   sessions: cell of strings of sessions to be included (e.g. {'T0', 'T1'})
  %   include: string/cell of strings, that must be in column name
  %   exclude: string/cell of strings, that must NOT be in column name

  n_cols = numel(spm_names);
  matrix = zeros(n_cols, n_cols);

  colnames = {};

  for i = 1:n_cols
    ses = generate_session_name(spm_names{i});
    colname = gen_colname(spm_names{i});
    colnames{end + 1} = colname;
    % Check if contrast for requested session
    if ~any(strcmp(sessions, ses))
      continue;
    end

    % Check if any of included in name
    res = regexp(colname, include, 'forceCellOutput');
    if ~any(cell2mat(res))
      continue;
    end

    % Check if any of excluded in name
    colname = gen_colname(spm_names{i});
    res = regexp(colname, exclude, 'forceCellOutput');
    if any(cell2mat(res))
      continue;
    end
    matrix(i, i) = 1;
  end
  empty = any(matrix, 2);
  tab = array2table(matrix, 'VariableNames', colnames, 'RowNames', colnames);
  tab(~empty, :) = [];

end
