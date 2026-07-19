(macro_invocation
  macro: (scoped_identifier
		   path: (identifier) @path
		   name: (identifier) @name
		   (#eq? @path "vulkano_shaders")
		   (#eq? @name "shader")
		   )
  (token_tree
	(identifier) @src
	(#eq? @src "src")
	(string_literal
	  (string_content) @injection.content
	  (#set! injection.language "glsl")
	  (#set! injection.combined)
	  )
	)
  )
