setlocal include=\v<(require\([''"]|import\s+[''"]|from\s+[''"])\zs[^''"]+
setlocal includeexpr=javascript#IncludeExpr(v:fname)

let g:javascript_node_modules = 1
