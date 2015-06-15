function test_all_bc1(setNo)

dbstop error;

t_param_derived_bc1(setNo);
test_bc1.work(setNo);
test_bc1.college(setNo);
test_bc1.calibr(setNo);
t_pvector;
t_devvect;
t_devstruct;


dbclear all;

end