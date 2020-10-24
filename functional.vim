" ------
" functional-style functions
" ------

function! Map(fr, li) abort
    " Return a copy of list, li, with fn applied to each element.
    " Example:
    "   Map(function("Some_function"), [1,2,3])
    "   Map({i -> 2*i}, [1,2,3])
    " Args:
    "   fr (Funcref): Funcref to a function taking a single input arg
    "   li (list):

    let l:new_list = deepcopy(a:li)
    call map(l:new_list, {i, value -> a:fr(value)})
    return l:new_list
endfunction


function! Reduce(fr, li) abort
    " Return the result of a reduction operation applied to a list.
    " Example:  Reduce({i, j -> i + j}, [1,2,3]), returns 6
    "           Reduce({i, j -> i . j}, ['hello ', 'world'], returns 'hello world'
    "
    " Args:
    "   fr (Funcref): Funcref taking 2 input args
    "   li (list):
    
    " first reduction
    let l:reduced = a:fr(a:li[0], a:li[1])

    " subsequent reductions
    if len(a:li) > 2
        for index in range(2, len(a:li) - 1)
            let l:reduced = a:fr(l:reduced, a:li[index])  
        endfor
    endif

    return l:reduced
endfunction


function! Filter(fr, li)
    " Return a list of only those elements for which fr(element) = 1 
    " Example:
    "   Filter({i -> i > 1}, [1,2,3])
    "   Filter(function("Some_func"), [1,2,3])
    " Args:
    "   fr (Funcref): Funcref taking a single arg 
    "   li (list):

    let l:new_list = [] 
    for element in a:li
        if a:fr(element) == 1
            call add(l:new_list, element)
        endif
    endfor

    return l:new_list
endfunction


function! Zip(...) abort
    " Return a list of tuples assembled from lists of the same size.
    "
    " Example: Zip([1,2,3], ['a','b','c']), returns [[1,'a'],[2, 'b'],[3, 'c']]
    " ------
    let l:zipped = []
    for index in range(len(a:1))
        let l:new_sublist = []
        for li in a:000
            call add(l:new_sublist, li[index])
        endfor
        call add(l:zipped, l:new_sublist)
    endfor

    return  l:zipped
endfunction


function! Unzip(zipped_list) abort
    " Return list of unzipped lists.
    "
    " Example: Unzip([[1,'a'],[2,'b'],[3,'c']]), returns [[1,2,3],
    " ['a','b','c']]

    let l:unzipped = []
    for element_index in range(len(zipped_list[0]))
        call add(l:unzipped, Map({i -> i[element_index]}, zipped_list))         
    endfor

    return l:unzipped

endfunction


function! Sorted(li, kwargs = {'key':{i -> i}, 'reverse':0}) abort
    " Return a sorted list, sorted according to the order of corresponding list 
    " Map(kwargs['key'],li)
    "
    " Defaults to sorting in ascending order.
    "
    " Example:
    "   Sorted([2,1,3])
    "   Sorted([2,1,3], {'key':{i -> abs(i)}, 'reverse':1})
    "   Sorted([2,1,3], {'key':function("Some_func")})
    " Args:
    "   li (list):
    "   kwargs (dict): (optional)
    "       kwargs["key"] (Funcref):
    "           sort li according to order of Mapped(kwargs['key'], li)
    "       kwargs["reverse"] (0,1): 
    "           0 : default - sort ascending
    "           1 : sort descending
    "
  
    " get a 'shadow' list of [[element, kwargs['key'](element)],..]
    let l:shadow_list = Zip(a:li, Map(a:kwargs['key'], a:li))
    echo l:shadow_list

    " sort the list based tuples, based on the kwargs['key'] values
    if a:kwargs['reverse'] == 0
        let l:sorted_shadow_list  = sort(l:shadow_list, 
                    \{i, j-> i[1]==j[1] ? 0: i[1] > j[1] ? 1 : -1})
    else
        let l:sorted_shadow_list  = sort(l:shadow_list, 
                    \{i, j-> i[1]==j[1] ? 0: i[1] > j[1] ? -1 : 1})
    endif

    " collect the original list terms, in their new sorted order
    return Map({i->i[0]}, l:sorted_shadow_list)
endfunction


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

