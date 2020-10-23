" ------
" Miscellaneous useful functions to co-opt nicer way of programming vimscript
" ------

function! In(value, li) abort
    " Return 1 if value in list, li: Else return 0
    for i in a:li
        if i == a:value
            return 1
        endif  
    endfor
    return 0
endfunction

" ------
" functional-style functions
" ------

function! Map(fn, li) abort
    " Return a list, with fn applied to each element.
    " Args:
    "   fn (Funcref): the output from function("Some_function")
    "   li (list):

    let l:new_list = deepcopy(a:li)
    call map(l:new_list, string(a:fn) . '(v:val)')
    return l:new_list
endfunction

function! Return(i) abort
    " Return the same value input.
    return a:i
endfunction

function! Zip(...) abort
    " Return a list of tuples assembled from lists of the same size.
    "
    " Example: Zip([1,2,3], ['a', 'b', 'c']), returns [[1, 'a'], [2, 'b'], [3, 'c']]
    " ------
    
    let l:new_list = []
    for i in range(len(a:1))
        let l:new_sublist = []
        for li in a:000
            call add(l:new_sublist, li[i])
        endfor
        call add(l:new_list, l:new_sublist)
    endfor

    return  l:new_list
endfunction

function! Sorted_hidden(i, j) abort
    return a:i[1] == a:j[1] ? 0 : a:i[1] > a:j[1] ? 1 : -1
endfunction

function! Sorted(li, kwargs = {'key':function('Return'), 'reverse':0}) abort
    " Return a sorted list. Defaults to sorting in ascending order.
    " Args:
    "   li (list):
    "   kwargs (dict): (optional)
    "       kwargs["key"] (Funcref):
    "           sort li according to order of Mapped(kwargs['key'], li)
    "       kwargs["reverse"] (0,1): 
    "           0 : default - sort ascending
    "           1 : sort descending
    "
    " Example:
    "   Sorted([1,2,3])
    "   Sorted([1,2,3], {'key':function("Some_func")})
    "   Sorted([1,2,3], {'key':function("Some_func"), 'reverse':1})
  
    " get a 'hidden list' of kwargs['key'] applied to each element of li
    let l:hidden_list = Map(a:kwargs['key'], a:li)

    " get a list of [[li[0], hidden[0]],...] sorted by hidden values
    " (ascending)
    let l:zipped_lists = Zip(a:li, l:hidden_list)
    let l:zipped_sorted  = sort(l:zipped_lists, 'Sorted_hidden')

    " collect the original list term, in order according to hidden values
    let l:return_list = []
    for tuple in l:zipped_sorted
        call add(l:return_list, tuple[0]) 
    endfor

    " handle reverse condition
    if kwargs['reverse']
        return reverse(l:return_list)
    else
        return l:return_list
    endif

endfunction
