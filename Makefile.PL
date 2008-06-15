use inc::Module::Install;
name 'Sledge-Plugin-ShowImage';
all_from 'lib/Sledge/Plugin/ShowImage.pm';

# requires '';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;
