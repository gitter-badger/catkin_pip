message(STATUS "Loading catkin-pip.cmake from ${CMAKE_CURRENT_LIST_DIR}... ")

#defining our variables
if ( NOT CATKIN_PIP_REQUIREMENTS_PATH )
    set (CATKIN_PIP_REQUIREMENTS_PATH ${CMAKE_CURRENT_LIST_DIR})
endif()

if ( NOT CATKIN_PIP_GLOBAL_PYTHON_DESTINATION )
    # using site-packages as it s the default for pip and should also be used on debian systems for installs from non system packages
    # Explanation here : http://stackoverflow.com/questions/9387928/whats-the-difference-between-dist-packages-and-site-packages
    set (CATKIN_PIP_GLOBAL_PYTHON_DESTINATION "lib/python2.7/site-packages")
endif()

# _setup_util.py should already exist here.
# catkin should have done the workspace setup before we reach here
if ( EXISTS ${CATKIN_DEVEL_PREFIX}/_setup_util.py )
    file(READ ${CATKIN_DEVEL_PREFIX}/_setup_util.py  SETUP_UTIL_PY)
    string(REPLACE
        "'PYTHONPATH': 'lib/python2.7/dist-packages',"
        "'PYTHONPATH': ['lib/python2.7/dist-packages', '${CATKIN_PIP_GLOBAL_PYTHON_DESTINATION}']"
        PATCHED_SETUP_UTIL_PY
        ${SETUP_UTIL_PY}
    )
    file(WRITE ${CATKIN_DEVEL_PREFIX}/_setup_util.py  ${PATCHED_SETUP_UTIL_PY})
else()
    message(FATAL_ERROR "SETUP_UTIL.PY DOES NOT EXISTS YET ")
endif()

# Since we need (almost) the same configuration for both devel and install space, we create cmake files for each workspace setup.
set(CONFIGURE_PREFIX ${CATKIN_DEVEL_PREFIX})
configure_file(${CMAKE_CURRENT_LIST_DIR}/catkin-pip-setup.cmake.in ${CONFIGURE_PREFIX}/.catkin-pip-setup.cmake @ONLY)

set(CONFIGURE_PREFIX ${CMAKE_INSTALL_PREFIX})
configure_file(${CMAKE_CURRENT_LIST_DIR}/catkin-pip-setup.cmake.in ${CONFIGURE_PREFIX}/.catkin-pip-setup.cmake @ONLY)

unset(CONFIGURE_PREFIX)

# Overriding default pip command options to work for devel workspace (package is editable in devel/ and we reuse system pip packages when possible)
#Note: -e option is not compatible with some other options... so we use a different way than default commands (in catkin-pip-setup.cmake.in).
#Note: resist the temptation to access CONFIGURE_PREFIX directly from here. it should be set in the macro using that variable to avoid mixups.
if ( NOT CATKIN_PIP_OPT_INSTALL_PACKAGE )
    set(CATKIN_PIP_OPT_INSTALL_PACKAGE -q install -e \@package_arg\@ --install-option "--install-dir=\@CONFIGURE_PREFIX\@/${CATKIN_GLOBAL_PYTHON_DESTINATION}" --install-option "--script-dir=\@CONFIGURE_PREFIX\@/${CATKIN_GLOBAL_BIN_DESTINATION}")
endif()

#Note : we don't want to force reinstalling requirements for dev here (we'll use the system pip packages if they satisfy requirements).
if ( NOT CATKIN_PIP_OPT_INSTALL_REQUIREMENTS )
    set(CATKIN_PIP_OPT_INSTALL_REQUIREMENTS install -r \@requirements_arg\@ --install-option "--install-dir=\@CONFIGURE_PREFIX\@/${CATKIN_GLOBAL_PYTHON_DESTINATION}" --install-option "--script-dir=\@CONFIGURE_PREFIX\@/${CATKIN_GLOBAL_BIN_DESTINATION}")
endif()

if ( NOT CATKIN_PIP_OPT_INSTALL_REQUIREMENTS_AND_PACKAGE )
    set(CATKIN_PIP_OPT_INSTALL_REQUIREMENTS_AND_PACKAGE install -r \@requirements_arg\@ -e @package_arg\@ --install-option "--install-dir=\@CONFIGURE_PREFIX\@/${CATKIN_GLOBAL_PYTHON_DESTINATION}" --install-option "--script-dir=\@CONFIGURE_PREFIX\@/${CATKIN_GLOBAL_BIN_DESTINATION}")
endif()

# And here we need to do the devel workspace setup.
include(${CATKIN_DEVEL_PREFIX}/.catkin-pip-setup.cmake)

# Official macros for use by package to make it usable with catkin.
macro(catkin_pip_requirements requirements_txt )
    catkin_pip_requirements_prefix(${requirements_txt})
endmacro()

# This should be called with only one argument, it is assumed to be the package path
# catkin_pip_package(${CMAKE_CURRENT_SOURCE_DIR}/mypkg)
# If no arguments are passed, the package path is assumed to be ${CMAKE_CURRENT_SOURCE_DIR}
# catkin_pip_package()
macro(catkin_pip_package)

    set (extra_macro_args ${ARGN})

    # Did we get any optional args?
    list(LENGTH extra_macro_args num_extra_args)
    if (${num_extra_args} GREATER 0)  # 1 arg
        list(GET extra_macro_args 0 package_path)
    else()  # 0 arg
        set(package_path .)
    endif()
    #message ("Got package_path: ${package_path}")
    catkin_pip_package_prefix(${package_path})

    # Setting up the command for install space for user convenience
    # We ignore requirements here (since setup.py only should be used for install dependencies)
    install(CODE "
        #Setting paths for install by including our configured install cmake file
        include(${CMAKE_INSTALL_PREFIX}/.catkin-pip-setup.cmake)
        # note this should use the default pip commands (non editable package)
        catkin_pip_package_prefix(${package_path})
    ")
endmacro()

# This should be called with requirements files path and package path like this
# catkin_pip_requirements_package(./mypkg/requirements.txt ./mypkg)
# If there is only one argument, it is assumed to be the requirements path and package path is set to '.'
# catkin_pip_requirements_package(./mypkg/requirements.txt)
# If no arguments are passed, we assume there is no requirements to install.
# catkin_pip_requirements_package()
macro(catkin_pip_requirements_package)

    set (extra_macro_args ${ARGN})

    # Did we get any optional args?
    list(LENGTH extra_macro_args num_extra_args)
    if (${num_extra_args} GREATER 0)
        if (${num_extra_args} GREATER 1)  # 2 args
            list(GET extra_macro_args 0 requirements_path)
            #message ("Got requirements_path: ${requirements_path}")
            list(GET extra_macro_args 1 package_path)
            #message ("Got package_path: ${package_path}")
        else()  # 1 arg
            list(GET extra_macro_args 0 requirements_path)
            #message ("Got requirements_path: ${requirements_path}")
            set(package_path .)
            #message ("Got package_path: ${package_path}")
        endif()
        catkin_pip_requirements_package_prefix(${requirements_path} ${package_path})
    else()  # 0 arg
        set(package_path .)
        #message ("Got package_path: ${package_path}")
        catkin_pip_package_prefix(${package_path})
    endif()

    # Setting up the command for install space for user convenience
    # We ignore requirements here (since setup.py only should be used for install dependencies)
    install(CODE "
        #Setting paths for install by including our configured install cmake file
        include(${CMAKE_INSTALL_PREFIX}/.catkin-pip-setup.cmake)
        # note this should use the default pip commands (non editable package)
        catkin_pip_package_prefix(${package_path})
    ")
endmacro()

# Extension of find_program that allows checking for version of package and provide additional
# - "VERSION_PACKAGE pippkgname"
# - "VERSION_MIN vernum"
# - "VERSION_EXACT vernum"
# to allow the user to specify which version of program, provided by a catkin package he actually needs
# We assume the version of the program
macro(find_catkin_pip_package)
#    foreach(ARG ${ARGV})
#        if(STREQUAL ${arg} VERSION_MIN)
#    endforeach()

#    find_program(${ARGV})
endmacro()

# TODO :
# VERBOSE OPTION to help debugging pip commands
# install pip packages to be embedded with install workspace. BUT not in catkin deb package... ?
# CPACK to deb : investigate https://cmake.org/pipermail/cmake/2011-February/042687.html ?
# dh-virtualenv for deb builds ?
