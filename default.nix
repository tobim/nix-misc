self: super:
{
  ccls = super.callPackage pkgs/ccls {
    llvmPackages = super.llvmPackages_6;
  };

  cmake_3_12 = super.libsForQt5.callPackage pkgs/cmake/3.12.nix { };

  cmake_3_7 = super.callPackage pkgs/cmake/3.7.nix { };
  cmake_3_2 = super.callPackage pkgs/cmake/3.2.nix {
    inherit (super.darwin) ps;
  };
  cmake_3_1 = (self.cmake_3_2.overrideAttrs (oldAttrs: {
    name = "cmake-3.1";
    majorVersion = "3.1";
    src = super.fetchurl {
      url = "https://cmake.org/files/v3.1/cmake-3.1.3.tar.gz";
      sha256 = "1l662p9lscbzx9s85y86cynb9fn1rb2alqg4584wqq9gibxd7x25";
    };
  }));
  cmake_3_0 = super.callPackage pkgs/cmake/3.0.nix { };
}
