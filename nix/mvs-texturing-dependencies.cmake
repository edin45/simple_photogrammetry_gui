# nix/mvs-texturing.nix supplies these dependencies before CMake runs.
# Keep these empty targets because the rest of the upstream build names them.
add_custom_target(ext_mapmap)
add_custom_target(ext_rayint)
add_custom_target(ext_eigen)
add_custom_target(ext_mve)
