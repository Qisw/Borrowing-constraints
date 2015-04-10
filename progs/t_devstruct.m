function t_devstruct

n = 3;
d = devstruct('name1', 'short1', 'long description 1', randn([n,1]), randn([n,1]), rand([n,1]), 0.7, ...
   '%.3f');

disp(d.short_display);

end