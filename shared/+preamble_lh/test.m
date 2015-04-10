function test

baseDir = '/users/lutz/Documents/temp/';
dataFn  = [baseDir, 'preamble_data.mat'];
texFn   = [baseDir, 'preamble_test.tex'];

preamble_lh.initialize(dataFn, texFn);

preamble_lh.add_field('alpha', 'alpha value', dataFn);
preamble_lh.add_field('beta',  'beta value',  dataFn);

preamble_lh.add_field('beta',  'new beta value',  dataFn);


preamble_lh.write_tex(dataFn);

end