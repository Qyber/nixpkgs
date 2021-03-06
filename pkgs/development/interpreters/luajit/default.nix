{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name    = "luajit-${version}";
  version = "2.1.0-beta2";
  luaversion = "5.1";

  src = fetchurl {
    url    = "http://luajit.org/download/LuaJIT-${version}.tar.gz";
    sha256 = "0iyghj1xjlmd9ywa4flf9yszynf3jhbp0yqb9b49k7ab0g528fbi";
  };

  enableParallelBuilding = true;

  patchPhase = ''
    substituteInPlace Makefile \
      --replace /usr/local $out

    substituteInPlace src/Makefile --replace gcc cc
  '' + stdenv.lib.optionalString (stdenv.cc.libc != null)
  ''
    substituteInPlace Makefile \
      --replace ldconfig ${stdenv.cc.libc.bin or stdenv.cc.libc}/bin/ldconfig
  '';

  configurePhase = false;
  buildFlags     = [ "amalg" ]; # Build highly optimized version
  installPhase   = ''
    make install INSTALL_INC=$out/include PREFIX=$out
    ln -s $out/bin/luajit* $out/bin/lua
    ln -s $out/bin/luajit* $out/bin/luajit
  '';

  meta = with stdenv.lib; {
    description = "High-performance JIT compiler for Lua 5.1";
    homepage    = http://luajit.org;
    license     = licenses.mit;
    platforms   = platforms.linux ++ platforms.darwin;
    maintainers = with maintainers ; [ thoughtpolice smironov ];
  };
}
