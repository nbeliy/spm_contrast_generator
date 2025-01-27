function out = gen_colname(spm_name)
  res = regexp(spm_name, ' ', 'split');

  ses = generate_session_name(res{1});

  base = regexp(res{2}, '*', 'split');
  base = base{1};

  res = regexp(base, 'xRT');
  if isempty(res)
    mod = '';
  else
    mod = '_mod';
    base = base(1:res(1) - 1);
  end

  out = [base mod '_' ses];

end
