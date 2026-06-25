#' @keywords internal
compare_with_git <- function(input_file, git_file) {

  # Prepare return value
  copy_to_git <- FALSE

  if (!file.exists(input_file)) stop(input_file, " does not exist")

  if (file.exists(git_file)) {
    message(basename(input_file), " is already under version control")

    # If the file has changed compared to the local version kept in git,
    # tell the user that the file has been changed in the input directory.
    # When in interactive use, ask them to check if the change should be kept.
    # If not, stop and ask the user to check the input file for
    # changes and revert them if they were unintended.
    # When not in interactive use, stop with an informative message.
    if (tools::md5sum(input_file) != tools::md5sum(git_file)) {
      if (interactive()) {
        answer <- readline(prompt = paste0(
          "The file is under version control but has been changed in the input directory\n",
          "Do you want to keep the change and replace the old version in the git repository? (y/n) "))
        if (tolower(answer) == "y") {
          message("Keeping the change and replacing the old version in the git repository")
          message("Remember to check the diff in the JSON representation after running 99_derappp.R")
          copy_to_git <- TRUE
        } else {
          stop("Please check the input file for unintended changes")
        }
      } else {
        stop(
          "The file is under version control but has been changed in the input directory\n",
          "Please check if the change should be kept.\n",
          "If yes, remove the old version in the git repository, e.g. using\n",
          "rm ", git_file, "\n",
          "and check the diff in the JSON representation after running 99_derappp.R")
      }
    } else {
      copy_to_git <- FALSE
    }
  }
  return(copy_to_git)
}
