name "rack"
run_list ['recipe[nginx::default]', 'recipe[nodejs::default]']