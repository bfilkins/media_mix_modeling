#### Option 1: nevergrad installation via PIP
# 1. load reticulate
library("reticulate")
# 2. create virtual environment
virtualenv_create("r-reticulate")
# 3. use the environment created
use_virtualenv("r-reticulate", required = TRUE)
# 4. point Python path to the python file in the virtual environment. Below is
#    an example for MacOS M1 or above. The "~" is my home dir "/Users/gufengzhou".
#    Show hidden files in case you want to locate the file yourself.
Sys.setenv(RETICULATE_PYTHON = "~/.virtualenvs/r-reticulate/bin/python")
# 5. Check python path
py_config() # If the first path is not as 4, do 6
# 6. Restart R session, run #4 first, then load library("reticulate"), check
#    py_config() again, python should have path as in #4
# 7. Install numpy if py_config shows it's not available
py_install("numpy", pip = TRUE)
# 8. Install nevergrad
py_install("nevergrad", pip = TRUE)
# 9. If successful, py_config() should show numpy and nevergrad with installed paths
# 10. Everytime R session is restarted, you need to run #4 first to assign python
#    path before loading Robyn
# 11. Alternatively, add the line RETICULATE_PYTHON = "~/.virtualenvs/r-reticulate/bin/python"
#    in the file Renviron in the the R directory to force R to always use this path by
#    default. Run R.home() to check R path, then look for file "Renviron". This way, you
#    don't need to run #4 everytime. Note that forcing this path impacts other R instances
#    that requires different Python versions
