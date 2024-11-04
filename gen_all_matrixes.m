table_name = 'contrasts_sessionbysession.xlsx';
%subtables = {'T0', 'T1', 'T1_T0'};
subtables = {'T0'};

for it = 1:numel(subtables)
  contrast.(subtables{it}) = generate_matrix(table_name, subtables{it}, false);
end

save('contrast_table.mat', 'contrast');

