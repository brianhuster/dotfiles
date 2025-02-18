" @see https://bun.sh/docs/runtime/modules
" I removed `.jsm`, `.es`, `.es6` because they are not popular, not
" standardized, no JS runtime can automatically find them, they also have no
" build tools. If users want to use those filetypes, they should write module
" name with those extensions (for example `import './foo.jsm';`).
let s:extensions = ['.tsx', '.jsx', '.ts', '.vue', '.mjs', '.js', '.cjs', '.json', '/index.tsx', '/index.jsx', '/index.ts', '/index.vue', '/index.mjs', '/index.js', '/index.cjs', '/index.json']

exe 'setlocal suffixesadd^=' . join(s:extensions, ',')

setlocal include=\v<(require\([''"]|import\s+[''"]|from\s+[''"])\zs[^''"]+
setlocal includeexpr=javascript#IncludeExpr(v:fname)

let g:javascript_node_modules = 1
