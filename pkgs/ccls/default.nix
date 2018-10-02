{ stdenv, fetchFromGitHub, makeWrapper
, cmake, llvmPackages, ncurses }:

let
  src = fetchFromGitHub {
    owner = "MaskRay";
    repo = "ccls";
    rev = "43c3df6f28458c73a9bbc2ac99ec8e7472ca004c";
    sha256 = "1zgpnbdlfhxbbpfgv9878lhir8ihifgzwmjckxzc72dw829w281k";
    fetchSubmodules = true;
  };

  stdenv = llvmPackages.stdenv;

in
stdenv.mkDerivation rec {
  name    = "ccls-${version}";
  version = "2018-09-09";

  inherit src;

  nativeBuildInputs = [ cmake makeWrapper ];
  buildInputs = with llvmPackages; [ clang clang-unwrapped llvm ncurses ];

  cmakeFlags = [
    "-DSYSTEM_CLANG=ON"
    "-DCLANG_CXX=ON"
    "-DCMAKE_OSX_DEPLOYMENT_TARGET=10.13"
  ];

  shell = stdenv.shell;
  postFixup = ''
    # We need to tell ccls where to find the standard library headers.

    standard_library_includes="\\\"-isystem\\\", \\\"${if (stdenv.hostPlatform.libc == "glibc") then stdenv.cc.libc.dev else stdenv.cc.libc}/include\\\""
    standard_library_includes+=", \\\"-isystem\\\", \\\"${llvmPackages.libcxx}/include/c++/v1\\\""
    export standard_library_includes

    wrapped=".ccls-wrapped"
    export wrapped

    mv $out/bin/ccls $out/bin/$wrapped
    substituteAll ${./wrapper} $out/bin/ccls
    chmod --reference=$out/bin/$wrapped $out/bin/ccls
  '';

  doInstallCheck = false;
  installCheckPhase = ''
    pushd ${src}
    $out/bin/ccls --ci --test-unit
  '';

  meta = with stdenv.lib; {
    description = "A c/c++ language server powered by clang";
    homepage    = https://github.com/MaskRay/ccls;
    license     = licenses.mit;
    platforms   = platforms.linux ++ platforms.darwin;
    maintainers = [ maintainers.tobim ];
  };
}
