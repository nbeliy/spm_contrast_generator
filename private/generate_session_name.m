function res = generate_session_name(session_id)
  % Generates session string as in intable from session id as in SPM file
  % For ex: 'Sn(1)' --> 'T0'
  % Need to be changed if session naming is changed

  % This retrieve the session number from Sn(X) string
  tok = regexp(session_id, 'Sn\(([0-9]+)\)', 'tokens');
  ses_num = str2double(tok{1}{1});

  % This transforms session number to Session name
  res = sprintf('T%d', ses_num - 1);
end
