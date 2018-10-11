{ stdenv, fetchurl
, bzip2, curl, expat, libarchive, xz, zlib
, ps
, useSharedLibraries ? (!stdenv.isCygwin)
, useNcurses ? false, ncurses
, useQt4 ? false, qt4
}:

with stdenv.lib;

let
  os = stdenv.lib.optionalString;
  majorVersion = "3.1";
  minorVersion = "3";
  version = "${majorVersion}.${minorVersion}";
in

stdenv.mkDerivation rec {
  name = "cmake-${os useNcurses "cursesUI-"}${os useQt4 "qt4UI-"}${version}";

  inherit majorVersion;

  src = fetchurl {
    url = "${meta.homepage}files/v${majorVersion}/cmake-${version}.tar.gz";
    sha256 = "1l662p9lscbzx9s85y86cynb9fn1rb2alqg4584wqq9gibxd7x25";
  };

  enableParallelBuilding = true;

  patches =
    # Don't search in non-Nix locations such as /usr, but do search in
    # Nixpkgs' Glibc.
    optional (stdenv ? glibc) ./search-path-3.0.patch ++
    optional (stdenv ? cross) (fetchurl {
      name = "fix-darwin-cross-compile.patch";
      url = "http://public.kitware.com/Bug/file_download.php?"
          + "file_id=4981&type=bug";
      sha256 = "16acmdr27adma7gs9rs0dxdiqppm15vl3vv3agy7y8s94wyh4ybv";
    });

  buildInputs =
    [ setupHook bzip2 curl expat libarchive xz zlib ]
    ++ optional useNcurses ncurses
    ++ optional useQt4 qt4;

  propagatedBuildInputs = [ ps ];

  CMAKE_PREFIX_PATH = stdenv.lib.concatStringsSep ":" buildInputs;

  configureFlags =
    "--docdir=/share/doc/${name} --mandir=/share/man --system-libs"
    + stdenv.lib.optionalString useQt4 " --qt-gui";

  setupHook = ./setup-hook.sh;

  dontUseCmakeConfigure = true;

  preConfigure = optionalString (stdenv ? glibc)
    ''
      fixCmakeFiles .
      substituteInPlace Modules/Platform/UnixPaths.cmake \
        --subst-var-by libc_bin ${getBin stdenv.cc.libc} \
        --subst-var-by libc_dev ${getDev stdenv.cc.libc} \
        --subst-var-by libc_lib ${getLib stdenv.cc.libc}
      substituteInPlace Modules/FindCxxTest.cmake \
        --replace "$""{PYTHON_EXECUTABLE}" ${stdenv.shell}
      configureFlags="--parallel=''${NIX_BUILD_CORES:-1} $configureFlags"
    '';

  hardeningDisable = [ "format" ];

  meta = {
    homepage = http://www.cmake.org/;
    description = "Cross-Platform Makefile Generator";
    platforms = if useQt4 then qt4.meta.platforms else stdenv.lib.platforms.all;
    maintainers = with stdenv.lib.maintainers; [ urkud mornfall ];
  };
}
