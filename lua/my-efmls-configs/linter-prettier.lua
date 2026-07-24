local fs = require('efmls-configs.fs')
local sourceText = require('efmls-configs.utils').sourceText

local linter = 'prettier'
local command = string.format(
  "%s --stdin-filepath '${INPUT}' --config-precedence prefer-file",
  -- "%s --stdin-filepath '${INPUT}' ${--range-start:charStart} ${--range-end:charEnd} --config-precedence prefer-file",
  fs.executable(linter, fs.Scope.NODE)
)

return {
  prefix = linter .. '.linter',
  lintSource = sourceText(linter .. '.linter'),
  lintCommand = command,
  lintStdin = true,
  lintFormats = { '[%trror]\\ %f:\\ %m\\ (%l:%c)', '%-G%.%#' },
  lintIgnoreExitCode = true,
  -- lintIgnoreExitCode = false,
  rootMarkers = {
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.js',
    '.prettierrc.yml',
    '.prettierrc.yaml',
    '.prettierrc.json5',
    '.prettierrc.mjs',
    '.prettierrc.cjs',
    '.prettierrc.toml',
    'prettier.config.js',
    'prettier.config.cjs',
    'prettier.config.mjs',
  },
}
