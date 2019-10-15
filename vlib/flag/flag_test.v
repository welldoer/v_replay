
import flag

fn test_if_flag_not_given_return_default_values() {
  mut fp := flag.new_flag_parser([]string)
  
  assert false == fp.bool('a_bool', false, '')
    && 42 == fp.int('an_int', 42, '')
    && 1.0 == fp.float('a_float', 1.0, '')
    && 'stuff' == fp.string('a_string', 'stuff', '')
}


fn test_could_define_application_name_and_version() {
  mut fp := flag.new_flag_parser([]string)
  fp.application('test app')
  fp.version('0.0.42')
  fp.description('some text')

  assert fp.application_name == 'test app'
    && fp.application_version == '0.0.42'
    && fp.application_description == 'some text'
}

fn test_bool_flags_do_not_need_an_value() {
  mut fp := flag.new_flag_parser(['--a_bool'])

  assert true == fp.bool('a_bool', false, '')
}

fn test_flags_could_be_defined_with_eq() {
  mut fp := flag.new_flag_parser([
    '--an_int=42', 
    '--a_float=2.0',
    '--bool_without',
    '--a_string=stuff',
    '--a_bool=true'])
  
  assert 42 == fp.int('an_int', 666, '')
    && true == fp.bool('a_bool', false, '')
    && true == fp.bool('bool_without', false, '')
    && 2.0 == fp.float('a_float', 1.0, '')
    && 'stuff' == fp.string('a_string', 'not_stuff', '')
}

fn test_values_could_be_defined_without_eq() {
  mut fp := flag.new_flag_parser([
    '--an_int', '42', 
    '--a_float', '2.0',
    '--bool_without',
    '--a_string', 'stuff',
    '--a_bool', 'true'])
  
  assert 42 == fp.int('an_int', 666, '')
    && true == fp.bool('a_bool', false, '')
    && true == fp.bool('bool_without', false, '')
    && 2.0 == fp.float('a_float', 1.0, '')
    && 'stuff' == fp.string('a_string', 'not_stuff', '')
}

fn test_values_could_be_defined_mixed() {
  mut fp := flag.new_flag_parser([
    '--an_int', '42', 
    '--a_float=2.0',
    '--bool_without',
    '--a_string', 'stuff',
    '--a_bool=true'])
  
  assert 42 == fp.int('an_int', 666, '')
    && true == fp.bool('a_bool', false, '')
    && true == fp.bool('bool_without', false, '')
    && 2.0 == fp.float('a_float', 1.0, '')
    && 'stuff' == fp.string('a_string', 'not_stuff', '')
}

fn test_beaware_for_argument_names_with_same_prefix() {
  mut fp := flag.new_flag_parser([
    '--short', '5', 
    '--shorter=7'
    ])
  
  assert 5 == fp.int('short', 666, '')
    && 7 == fp.int('shorter', 666, '')
}

fn test_beaware_for_argument_names_with_same_prefix_inverse() {
  mut fp := flag.new_flag_parser([
    '--shorter=7',
    '--short', '5', 
    ])
  
  assert 5 == fp.int('short', 666, '')
    && 7 == fp.int('shorter', 666, '')
}

fn test_allow_to_skip_executable_path() {
  mut fp := flag.new_flag_parser(['./path/to/execuable'])
  
  fp.skip_executable()
  
  args := fp.finalize() or {
    assert false
    return
  }
  assert !args.contains('./path/to/execuable')
}

fn test_none_flag_arguments_are_allowed() {
  mut fp := flag.new_flag_parser([
    'file1', '--an_int=2', 'file2', 'file3', '--bool_without', 'file4', '--outfile', 'outfile'])
  
  assert 2 == fp.int('an_int', 666, '')
    && 'outfile' == fp.string('outfile', 'bad', '')
    && true == fp.bool('bool_without', false, '')
}

fn test_finalize_returns_none_flag_arguments_ordered() {
  mut fp := flag.new_flag_parser(['d', 'b', 'x', 'a', '--outfile', 'outfile'])
  fp.string('outfile', 'bad', '')

  finalized := fp.finalize() or {
    assert false
    return
  }

  expected := ['d', 'b', 'x', 'a']
  mut all_as_expected := true 
  for i, v in finalized {
    all_as_expected = all_as_expected && v == expected[i]
  }
  assert all_as_expected
}

fn test_finalize_returns_error_for_unknown_flags() {
  mut fp := flag.new_flag_parser(['--known', '--unknown'])
  
  fp.bool('known', false, '')

  finalized := fp.finalize() or {
    assert err == 'Unknown argument \'unknown\''
    return
  }
  assert finalized.len < 0 // expect error to be returned
}

fn test_allow_to_build_usage_message() {
  mut fp := flag.new_flag_parser([]string)
  fp.limit_free_args(1, 4)
  fp.application('flag_tool')
  fp.version('v0.0.0')
  fp.description('some short information about this tool')

  fp.int('an_int', 666, 'some int to define')
  fp.bool('a_bool', false, 'some bool to define')
  fp.bool('bool_without_but_really_big', false, 'this should appear on the next line')
  fp.float('a_float', 1.0, 'some float as well')
  fp.string('a_string', 'not_stuff', 'your credit card number')
  
  usage := fp.usage()
  mut all_strings_found := true
  for s in ['flag_tool', 'v0.0.0', 
            'an_int <int>', 'a_bool', 'bool_without', 'a_float <float>', 'a_string <string>:not_stuff',
            'some int to define',
            'some bool to define',
            'this should appear on the next line',
            'some float as well',
            'your credit card number',
            'The arguments should be at least 1 and at most 4 in number.',
            'Usage', 'Options:', 'Description:',
            'some short information about this tool'] {
    if !usage.contains(s) {
      eprintln(' missing \'$s\' in usage message')
      all_strings_found = false
    }
  }
  assert all_strings_found
}

fn test_if_no_description_given_usage_message_does_not_contain_descpription() {
  mut fp := flag.new_flag_parser([]string)
  fp.application('flag_tool')
  fp.version('v0.0.0')

  fp.bool('a_bool', false, '')
  
  assert !fp.usage().contains('Description:')
}

fn test_if_no_options_given_usage_message_does_not_contain_options() {
  mut fp := flag.new_flag_parser([]string)
  fp.application('flag_tool')
  fp.version('v0.0.0')
  
  assert !fp.usage().contains('Options:')
}

fn test_free_args_could_be_limited() {
  mut fp1 := flag.new_flag_parser(['a', 'b', 'c'])
  fp1.limit_free_args(1, 4)
  args := fp1.finalize() or {
    assert false
    return
  }
  assert args[0] == 'a' && args[1] == 'b' && args[2] == 'c'
}

fn test_error_for_to_few_free_args() {
  mut fp1 := flag.new_flag_parser(['a', 'b', 'c'])
  fp1.limit_free_args(5, 6)
  args := fp1.finalize() or {
    assert err.starts_with('Expected at least 5 arguments')
    return
  }
  assert args.len < 0 // expect an error and need to use args 
}

fn test_error_for_to_much_free_args() {
  mut fp1 := flag.new_flag_parser(['a', 'b', 'c'])
  fp1.limit_free_args(1, 2)
  args := fp1.finalize() or {
    assert err.starts_with('Expected at most 2 arguments')
    return
  }
  assert args.len < 0 // expect an error and need to use args 
}

fn test_could_expect_no_free_args() {
  mut fp1 := flag.new_flag_parser(['a'])
  fp1.limit_free_args(0, 0)
  args := fp1.finalize() or {
    assert err.starts_with('Expected no arguments')
    return
  }
  assert args.len < 0 // expect an error and need to use args 
}

fn test_allow_abreviations() {
  mut fp := flag.new_flag_parser(['-v', '-o', 'some_file', '-i', '42', '-f', '2.0'])

  v := fp.bool_('version', `v`, false, '')
  o := fp.string_('output', `o`, 'empty', '')
  i := fp.int_('count', `i`, 0, '')
  f := fp.float_('value', `f`, 0.0, '')

  assert v && o == 'some_file' && i == 42 && f == 2.0

  u := fp.usage()
  assert u.contains(' -v') && u.contains(' -o') && u.contains(' -i') && u.contains(' -f')
}
