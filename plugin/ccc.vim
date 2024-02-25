if !get(g:, 'loaded_ccc', 0)
  finish
endif
let g:loaded_ccc = 1

highlight default link CccFloatNormal NormalFloat
highlight default link CccFloatBorder FloatBorder
