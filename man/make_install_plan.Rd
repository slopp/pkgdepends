% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pkginstall-api.R
\name{make_install_plan}
\alias{make_install_plan}
\title{Create a package installation plan}
\usage{
make_install_plan(pkgs, library = .libPaths()[[1]], config = list())
}
\arguments{
\item{pkgs}{Package names (or remote references) to install.}

\item{library}{Package library directory to install to. The packages
already installed there are considered for the install plan.}

\item{config}{Configuration options, see \link{remotes}.}
}
\value{
The install plan, a data frame.
}
\description{
TODO
}
