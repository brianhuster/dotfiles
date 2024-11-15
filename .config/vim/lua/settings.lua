vim.fn.job_start('ldconfig -p | grep libpython3', vim.dict({out_cb = function(chan, data)
	vim.o.pythonthreedll = vim.fn.split(data, '\n')[1]
end}))

