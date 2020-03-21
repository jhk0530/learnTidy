#' @export
#' @import learnr
#' @import rmarkdown
#'
myoutput <- function(dev = "png", smart = TRUE, theme = "rstudio",
                     highlight = "textmate", ace_theme = "textmate",
                     extra_dependencies = NULL, css = NULL, pandoc_args = NULL,
                     ...) {
  require(learnr)
  require(rmarkdown)

  args <- c(
    "--section-divs", "--template",
    rmarkdown::pandoc_path_arg(system.file("rmarkdown/templates/tutorial/resources/myformat.htm", package = "learnTidy"))
  )

  extra_dependencies <- list(rmarkdown::html_dependency_pagedtable())
  rmarkdown_pandoc_html_highlight_args <- getFromNamespace("pandoc_html_highlight_args", "rmarkdown")
  rmarkdown_is_highlightjs <- getFromNamespace("is_highlightjs", "rmarkdown")
  args <- c(args, rmarkdown_pandoc_html_highlight_args("default",highlight))
  if (rmarkdown_is_highlightjs(highlight)) {
    extra_dependencies <- append(extra_dependencies, list(rmarkdown::html_dependency_highlightjs(highlight)))
  }
  if (!identical(ace_theme, "textmate")) {
    ace_theme <- match.arg(ace_theme, ACE_THEMES)
    args <- c(args, "--variable", paste0(
      "ace-theme=",
      ace_theme
    ))
  }
  for (css_file in css) args <- c(args, "--css", pandoc_path_arg(css_file))
  stylesheets <- "tutorial-format.css"
  if (identical(theme, "rstudio")) {
    stylesheets <- c(stylesheets, "rstudio-theme.css")
    theme <- "cerulean"
  }

  extra_dependencies <- append(extra_dependencies, list(
    learnr::tutorial_html_dependency(),
    htmltools::htmlDependency( # tutorial_autocompletion_html_dependency()
      name = "tutorial-autocompletion",
      version = utils::packageVersion("learnr"),
      src = html_dependency_src("lib", "tutorial"),
      script = "tutorial-autocompletion.js"
    ),
    htmltools::htmlDependency( # tutorial_diagnostics_html_dependency(),
      name = "tutorial-diagnostics",
      version = utils::packageVersion("learnr"),
      src = html_dependency_src("lib", "tutorial"),
      script = "tutorial-diagnostics.js"
    ),
    htmltools::htmlDependency(
      name = "tutorial-format",
      version = utils::packageVersion("learnr"),
      src = system.file("rmarkdown/templates/tutorial/resources",
        package = "learnTidy"
      ), script = "tutorial-format.js",
      stylesheet = stylesheets
    )
  ))

  args <- c(args, pandoc_variable_arg("progressive","false"), pandoc_variable_arg("allow-skip", "false"))

  pandoc_options <- pandoc_options(
    to = "html4",
    from = rmarkdown::from_rmarkdown(TRUE),
    args = args,
    ext = ".html"
  )

  # knitr options ----------------------------------------

  knitr_options <- knitr_options_html(
    fig_width = 6.5,
    fig_height = 4,
    fig_retina = 2,
    keep_md = FALSE, dev
  )
  knitr_options$opts_chunk$max.print <- 1000

  # base format ------------------------------------------

  base_format <- rmarkdown::html_document(
    smart = smart,
    theme = theme,
    lib_dir = NULL,
    mathjax = "default",
    pandoc_args = pandoc_args,
    template = "default",
    extra_dependencies = extra_dependencies,
    bootstrap_compatible = TRUE,
    ...
  )

  rmarkdown::output_format(
    knitr = knitr_options,
    pandoc = pandoc_options,
    clean_supporting = FALSE,
    df_print = "paged",
    base_format = base_format
  )
}

html_dependency_src <- function(...) {
  if (nzchar(Sys.getenv("RMARKDOWN_SHINY_PRERENDERED_DEVMODE"))) {
    r_dir <- utils::getSrcDirectory(html_dependency_src, unique = TRUE)
    pkg_dir <- dirname(r_dir)
    file.path(pkg_dir, "inst", ...)
  }
  else {
    system.file(..., package = "learnr")
  }
}
