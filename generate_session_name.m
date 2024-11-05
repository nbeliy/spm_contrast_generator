function res = generate_session_name(session_id)
  % Generates session string as in intable from session id as in SPM file
  % For ex: 'Sn(1)' --> 'T0'
  % Need to be changed if session naming is changed
  tok = regexp(session_id, 'Sn\(([0-9]+)\)', 'tokens');
  res = ['T', num2str(str2double(tok{1}{1}) - 1)];
end
