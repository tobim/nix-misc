self: super:
{
  ccls = super.callPackage pkgs/ccls {
    llvmPackages = super.llvmPackages_6;
  };

  cmake_3_7 = super.callPackage pkgs/cmake/3.7.nix { };
  cmake_3_2 = super.callPackage pkgs/cmake/3.2.nix { };
  cmake_3_1 = super.callPackage pkgs/cmake/3.1.nix { };
  cmake_3_0 = super.callPackage pkgs/cmake/3.0.nix { };
}
