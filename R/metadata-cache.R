
#' @importFrom tools md5sum file_ext

CRANMetadataCache <- R6Class(
  "CRANMetadataCache",

  public = list(
    initialize = function() {
      private$data <- new.env(parent = emptyenv())
      invisible(self)
    },

    get = function(path) {
      path <- normalizePath(path)
      md5 <- md5sum(path)
      if (! is.null(res <- private$data[[md5]])) {
        res
      } else {
        private$insert_file(path, md5)
      }
    }
  ),

  private = list(
    data = NULL,

    insert_file = function(path, md5) {
      ext <- file_ext(path)
      if (ext == "gz") {
        private$insert_file_gz(path, md5)
      } else if (ext == "rds") {
        private$insert_file_rds(path, md5)
      }
    },

    insert_file_gz = function(path, md5) {
      pkgs <- format_packages_gz(read.dcf.gz(path))
      private$data[[md5]] <- pkgs
      pkgs
    },

    insert_file_rds = function(path, md5) {
      obj <- format_archive_rds(readRDS(path))
      private$data[[md5]] <- obj
      obj
    }
  )
)

#' @importFrom tibble as_tibble

format_packages_gz <- function(pkgs) {
  pkgs <- as_tibble(pkgs)
  list(pkgs = pkgs, deps = fast_parse_deps(pkgs))
}

format_archive_rds <- function(ards) {

  files <- sub("^[^/]+/", "", unlist(lapply(ards, rownames)))

  tibble(
    package = rep(names(ards), viapply(ards, nrow)),
    file = files,
    version = sub("^[^_]+_([-\\.0-9]+)\\.tar\\.gz$", "\\1", files),
    size = unlist(unname(lapply(ards, "[[", "size")))
  )
}

update_crandata_cache <- function(config, progress_bar) {
  type_cran_update_cache(
    rootdir   = config$metadata_cache_dir,
    platforms = config$platforms,
    rversions = config$`r-versions`,
    mirror    = config$`cran-mirror`,
    progress_bar
  )
}

update_biocdata_cache <- function(config, progress_bar) {
  type_bioc_update_cache(
    rootdir   = config$metadata_cache_dir,
    platforms = config$platforms,
    rversions = config$`r-versions`,
    progress_bar
  )
}
