
## ------------------------------------------------------------------------
## API

#' @importFrom desc desc
#' @export

#' @export

parse_remote.remote_specs_installed <- function(specs, config, ...) {
  parsed_specs <- re_match(specs, type_installed_rx())

  parsed_specs$ref <- parsed_specs$.text
  cn <- setdiff(colnames(parsed_specs), c(".match", ".text"))
  parsed_specs <- parsed_specs[, cn]
  parsed_specs$type <- "installed"
  lapply(
    seq_len(nrow(parsed_specs)),
    function(i) as.list(parsed_specs[i,])
  )
}

#' @export

resolve_remote.remote_ref_installed <- function(remote, direct, config,
                                                cache, dependencies, ...) {

  dsc <- desc(file.path(remote$library, remote$package))

  deps <- resolve_ref_deps(
    dsc$get_deps(), dsc$get("Remotes")[[1]], dependencies)
  deps <- deps[deps$type != "LinkingTo", ]

  files <- list(
    source = character(),
    target = NA_character_,
    platform = dsc$get_built()$Platform %|z|% "*",
    rversion = get_minor_r_version(dsc$get_built()$R),
    dir = NA_character_,
    package = dsc$get("Package")[[1]],
    version = dsc$get("Version")[[1]],
    deps = deps,
    needs_compilation = "false",
    status = "OK"
  )

  remote$description <- dsc

  structure(
    list(files = list(files), direct = direct, remote = remote,
         status = "OK"),
    class = c("remote_resolution_installed", "remote_resolution")
  )
}

#' @export

download_remote.remote_resolution_installed <- function(resolution,
                                                         config, mode, ...,
                                                         cache) {
  status <- make_dl_status("Had", NA_character_, NA_character_,
                           bytes = NA)
  async_constant(list(status))
}

#' @export

satisfies_remote.remote_resolution_installed <-
  function(resolution, candidate, config, ...) {
    TRUE
  }

## ----------------------------------------------------------------------
## Internal functions

type_installed_rx <- function() {
  paste0(
    "^",
    "(?:installed::)?",
    "(?<library>.*)/",
    "(?<package>", package_name_rx(), ")",
    "$"
  )
}
