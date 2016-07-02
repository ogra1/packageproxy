all: build

build:
	git clone https://anonscm.debian.org/git/pkg-ocaml-maint/packages/approx.git
	( cd approx; patch -p1 <../approx.patch; fakeroot debian/rules binary)

install:
	dpkg -x approx_*.deb $(DESTDIR)
