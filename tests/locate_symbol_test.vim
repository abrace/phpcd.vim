" Code dealing with test buffers is placed in 'try' blocks, and wiping of test
" buffers is done in 'finally' blocks, to ensure that the buffers are wiped
" even if an exception is thrown from the test code.  Unfortunately this
" prevents Vimunit from showing the correct line numbers for failed
" assertions; try to compensate by having a message for each assertion.

let s:supersame_mm_line = 18
let s:same_mm_line = 12
let s:same_na_line = 16
let s:same_pa_use_line = 14
let s:sameb_pa_use_line = 15
let s:same_ca_use_line = 17
let s:sameb_ca_use_line = 18
let s:same_getinstance_na_call_line = 20
let s:same_getinstance_nb_call_line = 21
let s:path_base = expand('%:p:h') . '/fixtures/PHPCD/'
let s:same_path = s:path_base . 'SameName/A/Same.php'
let s:supersame_path = s:path_base . 'SameName/A/SuperSame.php'
let s:sameb_path = s:path_base . 'SameName/B/Same.php'

function! TestCase_locate_new_Same_start()
	call s:check_locate_right_class(11, 18, s:same_path, 'new', 4, 0)
endfunction

function! TestCase_locate_new_Same_mid()
	call s:check_locate_right_class(11, 19, s:same_path, 'new', 4, 0)
endfunction

function! TestCase_locate_new_SameB_start()
	call s:check_locate_right_class(12, 18, s:sameb_path, 'new', 4, 0)
endfunction

function! TestCase_locate_new_SameB_mid()
	call s:check_locate_right_class(12, 19, s:sameb_path, 'new', 4, 0)
endfunction

function! TestCase_locate_Same_pa()
	call s:check_locate_right_class(s:same_pa_use_line, 13, s:same_path, '$a->', 10, 0)
endfunction

function! TestCase_locate_Sameb_pa()
	call s:check_locate_right_class(s:sameb_pa_use_line, 13, s:sameb_path, '$b->', 8, 0)
endfunction

function! TestCase_locate_Same_class_start()
	call s:check_locate_right_class(s:same_ca_use_line, 9, s:same_path, '', 4, 0)
endfunction

function! TestCase_locate_Same_class_mid()
	call s:check_locate_right_class(s:same_ca_use_line, 10, s:same_path, '', 4, 0)
endfunction

function! TestCase_locate_SameB_class_start()
	call s:check_locate_right_class(s:sameb_ca_use_line, 9, s:sameb_path, '', 4, 0)
endfunction

function! TestCase_locate_SameB_class_mid()
	call s:check_locate_right_class(s:sameb_ca_use_line, 10, s:sameb_path, '', 4, 0)
endfunction

function! TestCase_locate_Same_CA()
	call s:check_locate_right_class(s:same_ca_use_line, 15, s:same_path, 'Same::', 'const CA', 0)
endfunction

function! TestCase_locate_SameB_CA()
	call s:check_locate_right_class(s:sameb_ca_use_line, 16, s:sameb_path, 'SameB::', 'const CA', 0)
endfunction

function! TestCase_locate_getInstance()
	call s:check_locate_right_class(s:same_getinstance_na_call_line, 15, s:supersame_path, 'Same::', 9, 0)
endfunction

function! TestCase_locate_na_start()
	call s:check_locate_right_class(s:same_getinstance_na_call_line, 30, s:same_path, 'Same::getInstance()->', s:same_na_line, 0)
endfunction

function! TestCase_locate_na_mid()
	call s:check_locate_right_class(s:same_getinstance_na_call_line, 31, s:same_path, 'Same::getInstance()->', s:same_na_line, 0)
endfunction

function! TestCase_locate_nb_start()
	call s:check_locate_nonexistent_method(s:same_getinstance_nb_call_line, 30, 'Same::getInstance()->')
endfunction

function! TestCase_locate_nb_mid()
	call s:check_locate_nonexistent_method(s:same_getinstance_nb_call_line, 31, 'Same::getInstance()->')
endfunction

function! TestCase_locate_impl_start()
	call s:check_locate_abstract_function_impl(s:supersame_mm_line, 23, s:same_path, s:same_mm_line, 0)
endfunction

function! TestCase_locate_impl_mid()
	call s:check_locate_abstract_function_impl(s:supersame_mm_line, 24, s:same_path, s:same_mm_line, 0)
endfunction

function! s:check_locate_right_class(
	\cursor_line,
	\cursor_column,
	\expected_path,
	\expected_symbol_context,
	\expected_line_or_const,
	\expected_column)

	call s:check_locate_succeed(
		\a:cursor_line,
		\a:cursor_column,
		\a:expected_path,
		\a:expected_symbol_context,
		\a:expected_line_or_const,
		\a:expected_column,
		\'B/C/ExpectLocateRightClass.php')
endfunction

function! s:check_locate_nonexistent_method(
	\cursor_line,
	\cursor_column,
	\expected_symbol_context)

	call s:check_locate_fail(
		\a:cursor_line,
		\a:cursor_column,
		\a:expected_symbol_context,
		\'B/C/ExpectLocateRightClass.php')
endfunction

function! s:check_locate_abstract_function_impl(
	\cursor_line,
	\cursor_column,
	\expected_path,
	\expected_line_or_const,
	\expected_column)

	call s:check_locate_succeed(
		\a:cursor_line,
		\a:cursor_column,
		\a:expected_path,
		\'abstract function',
		\a:expected_line_or_const,
		\a:expected_column,
		\'SameName/A/SuperSame.php')
endfunction

function! s:check_locate_succeed(
	\cursor_line,
	\cursor_column,
	\expected_path,
	\expected_symbol_context,
	\expected_line_or_const,
	\expected_column,
	\relative_path_to_edit)

	call s:check_locate(
		\a:cursor_line,
		\a:cursor_column,
		\a:expected_symbol_context,
		\a:expected_path,
		\'expected path: ' . a:expected_path,
		\a:expected_line_or_const,
		\a:expected_column,
		\a:relative_path_to_edit)
endfunction

function! s:check_locate_fail(
	\cursor_line,
	\cursor_column,
	\expected_symbol_context,
	\relative_path_to_edit)

	call s:check_locate(
		\a:cursor_line,
		\a:cursor_column,
		\a:expected_symbol_context,
		\'',
		\'expect path to be empty',
		\'',
		\'',
		\a:relative_path_to_edit)
endfunction

function! s:check_locate(
	\cursor_line,
	\cursor_column,
	\expected_symbol_context,
	\expected_path,
	\expected_path_message,
	\expected_line_or_const,
	\expected_column,
	\relative_path_to_edit)

	below 1new
	exec ':silent! edit ' . s:path_base . a:relative_path_to_edit

	try
		call cursor(a:cursor_line, a:cursor_column)

		let [
			\symbol,
			\symbol_context,
			\symbol_namespace,
			\current_imports
		\] = phpcd#GetCurrentSymbolWithContext()

		call VUAssertEquals(
			\a:expected_symbol_context,
			\symbol_context,
			\'symbol_context should be "' . a:expected_symbol_context . '"')

		let [
			\symbol_file,
			\symbol_line,
			\symbol_col
		\] = phpcd#LocateSymbol(symbol, symbol_context, symbol_namespace, current_imports)

		call VUAssertEquals(
			\a:expected_path,
			\symbol_file,
			\a:expected_path_message)

		call VUAssertEquals(
			\a:expected_line_or_const,
			\symbol_line,
			\'expect line or const: ' . a:expected_line_or_const)
		call VUAssertEquals(a:expected_column, symbol_col, 'expect column ' . a:expected_column)
	finally
		silent! bw! %
	endtry
endfunction
