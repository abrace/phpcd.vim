" Code dealing with test buffers is placed in 'try' blocks, and wiping of test
" buffers is done in 'finally' blocks, to ensure that the buffers are wiped
" even if an exception is thrown from the test code.  Unfortunately this
" prevents Vimunit from showing the correct line numbers for failed
" assertions; try to compensate by having a message for each assertion.

function! TestCase_locate_new_Same_start()
	call s:check_locate_right_class(11, 18, 'A', 'new', 4, 0)
endfunction

function! TestCase_locate_new_Same_mid()
	call s:check_locate_right_class(11, 19, 'A', 'new', 4, 0)
endfunction

function! TestCase_locate_new_SameB_start()
	call s:check_locate_right_class(12, 18, 'B', 'new', 4, 0)
endfunction

function! TestCase_locate_new_SameB_mid()
	call s:check_locate_right_class(12, 19, 'B', 'new', 4, 0)
endfunction

function! TestCase_locate_Same_class_start()
	call s:check_locate_right_class(13, 9, 'A', '', 4, 0)
endfunction

function! TestCase_locate_Same_class_mid()
	call s:check_locate_right_class(13, 10, 'A', '', 4, 0)
endfunction

function! TestCase_locate_SameB_class_start()
	call s:check_locate_right_class(14, 9, 'B', '', 4, 0)
endfunction

function! TestCase_locate_SameB_class_mid()
	call s:check_locate_right_class(14, 10, 'B', '', 4, 0)
endfunction

function! TestCase_locate_impl_mid()
	call s:check_locate_impl(6, 24, 'A', 'abstract function', 6, 0)
endfunction

function! s:check_locate_right_class(
	\cursor_line,
	\cursor_column,
	\expected_namespace,
	\expected_symbol_context,
	\expected_line,
	\expected_column)

	call s:check_locate(
		\a:cursor_line,
		\a:cursor_column,
		\a:expected_namespace,
		\a:expected_symbol_context,
		\a:expected_line,
		\a:expected_column,
		\'B/C/ExpectLocateRightClass.php')
endfunction

function! s:check_locate_impl(
	\cursor_line,
	\cursor_column,
	\expected_namespace,
	\expected_symbol_context,
	\expected_line,
	\expected_column)

	call s:check_locate(
		\a:cursor_line,
		\a:cursor_column,
		\a:expected_namespace,
		\a:expected_symbol_context,
		\a:expected_line,
		\a:expected_column,
		\'SameName/A/SuperSame.php')
endfunction

function! s:check_locate(
	\cursor_line,
	\cursor_column,
	\expected_namespace,
	\expected_symbol_context,
	\expected_line,
	\expected_column,
	\relative_path_to_edit)

	let path_base = expand('%:p:h') . '/fixtures/PHPCD/'
	let path_to_edit = path_base . a:relative_path_to_edit
	let expected_path = path_base . 'SameName/' . a:expected_namespace . '/Same.php'
	below 1new
	exec ':silent! edit ' . path_to_edit

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
			\expected_path,
			\symbol_file,
			\'expect path for PHPCD\SameName\' . a:expected_namespace . '\Same')

		call VUAssertEquals(a:expected_line, symbol_line, 'expect line ' . a:expected_line)
		call VUAssertEquals(a:expected_column, symbol_col, 'expect column ' . a:expected_column)
	finally
		silent! bw! %
	endtry
endfunction
