function contrast = generate_contrast(var_names, base_table)

  row_names = base_table.Properties.RowNames;
  cols = base_table.Properties.VariableNames;

  contrast = array2table(zeros(numel(row_names), numel(var_names)));
  contrast.Properties.VariableNames = var_names;
  contrast.Properties.RowNames = row_names;

  for icol = 1:numel(cols)
    col_name = cols{icol};
    if any(ismember(contrast.Properties.VariableNames, col_name))
      if nnz(contrast.(col_name))
        error('Trying to update non-empty column %s (%s)',...
              col_name, num2xlcol(icol));
      end
      contrast.(col_name) = base_table.(col_name);
    else
      error('Trying to update missing column %s (%s)',...
            col_name, num2xlcol(icol));
    end
  end
  fprintf('Updated %d columns\n', numel(cols))
end
