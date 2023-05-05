# example R options set globally
options(width = 60)

# Set color output
# From https://github.com/r-lib/crayon/issues/24
options(crayon.enabled = TRUE)
old_hooks <- fansi::set_knit_hooks(knitr::knit_hooks, 
                                   which = c("output", "message", "error"))

# example chunk options set globally
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE
  )
