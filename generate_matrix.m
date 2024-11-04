function res = generate_matrix(intable, sheet, use_mod)

  if ~exist('use_mod', 'var')
      use_mod = false;
  end

  nsessions = 2;
  appendix = '_mod';

  T = readtable(intable,'Sheet', sheet, 'readrownames', true);
  len = size(T, 1);
  res = table(zeros([len, 0]));
  res.Properties.RowNames = T.Properties.RowNames;
  res.Var1 = [];

  vars = {};
  nans = {};

  for i = 1:size(T.Properties.VariableNames, 2)
    v = T.Properties.VariableNames{i};
    pos = regexp(v, '_');
    v = v(1 : pos(end) - 1);
    vars{i} = v;
    nans{i} = v(1: pos(1) - 1);
  end

  vars = unique(vars, 'stable');
  nans = unique(nans);

  physios = {};
  for i = 1:14
    physios{end + 1} = sprintf('R%d_2', i);
  end
  for i = 1:6
    physios{end + 1} = sprintf('R%d_1', i);
  end

  for s = 1:nsessions
    session = sprintf('_T%d', s - 1);
    for i = 1:numel(vars)
      loc_var = [vars{i}, session];
      loc_mod_var = [loc_var, appendix];
      res.(loc_var) = zeros([len, 1]);
      res.(loc_mod_var) = zeros([len, 1]);
      if any(ismember(T.Properties.VariableNames, loc_var))
        if use_mod
          res.(loc_mod_var) = T.(loc_var);
        else
          res.(loc_var) = T.(loc_var);
        end
      end
    end
    % Adding nan columns
    for i = 1:numel(nans)
      loc_var = [nans{i}, '_nan', session];
      if any(ismember(T.Properties.VariableNames, loc_var))
        continue;
      end
      res.(loc_var) = zeros([len, 1]);
    end
    % Adding Physio regressors
    for i = 1:numel(physios)
      loc_var = [physios{i}, session];
      if any(ismember(T.Properties.VariableNames, loc_var))
        continue;
      end
      res.(loc_var) = zeros([len, 1]);
    end
  end

  % Adding constant columns
  for s = 1:nsessions
    loc_var = sprintf('constant_T%d', s - 1);
    res.(loc_var) = zeros([len, 1]);
  end
end
