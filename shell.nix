with import <nixpkgs> {};
linux.overrideAttrs (o: { nativeBuildInputs = o.nativeBuildInputs ++ [
  b4
  ccache
  coccinelle
  ncurses
  openssl
  pkg-config
  sparse
  sphinx
  universal-ctags
];})
