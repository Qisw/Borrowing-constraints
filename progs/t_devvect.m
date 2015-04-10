function t_devvect

v = devvect(10);

n = 3;
nDev = 15;
for i1 = 1 : nDev
   ds = devstruct(sprintf('name%i', i1), sprintf('short%i', i1), sprintf('long%i', i1), ...
      randn([n,1]), randn([n,1]), rand([n,1]), 0.7, '%.2f');
   v = v.devadd(ds);
end

v.dev_display

% List all scalar devs
devV = v.scalar_devs;
disp(devV(:)');


end