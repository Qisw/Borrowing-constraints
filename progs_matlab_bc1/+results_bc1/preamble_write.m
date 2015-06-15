function preamble_write(cS)
% Write preamble file
%{
make sure preamble is written to correct dir
in case it is started on server
%}
% ---------------------------------------------

% Make sure the file name for the tex is local
fn = var_fn_bc1(cS.vPreambleData, cS);
m = load(fn);
pS = m.pS;
pS.texFn = cS.preambleFn;
save(fn, 'pS');

preamble_lh.write_tex(var_fn_bc1(cS.vPreambleData, cS));

end