# - This module looks for Cookiecutter
# Cookiecutter is a template management tool see https://cookiecutter.readthedocs.org/en/latest/
# Use this module by invoking find_package with the form::
#
#   find_package(Cookiecutter
#     [version] [EXACT]      # Minimum or EXACT version e.g. 1.4.0
#     [REQUIRED]             # Fail with error if Cookiecutter is not found
#   )
#
# This code sets the following variables:
#  Cookiecutter_EXECUTABLE       - The path to the cookiecutter command.
#  Cookiecutter_VERSION          - cookiecutter.__version__ value
#  Cookiecutter_MAJOR_VERSION    - Cookiecutter major version number (X in X.y.z)
#  Cookiecutter_MINOR_VERSION    - Cookiecutter minor version number (Y in x.Y.z)
#  Cookiecutter_PATCH_VERSION    - Cookiecutter subminor version number (Z in x.y.Z)
#  Cookiecutter_FOUND		     - Whether the cookiecutter tool has been found

MESSAGE(STATUS "Looking for cookiecutter...")

FIND_PACKAGE(Cookiecutter
  NAMES cookiecutter
  DOC "Cookiecutter template management tool https://cookiecutter.readthedocs.org/en/latest/"
)

# All configuration files which have been considered by CMake while searching for an installation of the package
# with an appropriate version are stored in the cmake variable <package>_CONSIDERED_CONFIGS, the associated versions in <package>_CONSIDERED_VERSIONS.

IF (Cookiecutter_FIND_VERSION_MAJOR OR Cookiecutter_FIND_VERSION_MINOR OR Cookiecutter_FIND_VERSION_PATCH)

ENDIF()

IF (Cookiecutter_EXECUTABLE)
  SET (Cookiecutter_FOUND "YES")
  MESSAGE(STATUS "Looking for cookiecutter... - found ${Cookiecutter_EXECUTABLE}")
ELSE (Cookiecutter_EXECUTABLE)
  IF (Cookiecutter_FIND_REQUIRED)
    MESSAGE(FATAL_ERROR "Looking for cookiecutter... - NOT found")
  ELSE (Cookiecutter_FIND_REQUIRED)
    MESSAGE(STATUS "Looking for cookiecutter... - NOT found")
  ENDIF (Cookiecutter_FIND_REQUIRED)
ENDIF (Cookiecutter_EXECUTABLE)

MARK_AS_ADVANCED(
  Cookiecutter_FOUND
  Cookiecutter_EXECUTABLE
  )