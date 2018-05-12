all: build

build:
	git clone https://salsa.debian.org/ocaml-team/approx.git
	( cd approx; patch -p1 <../approx.patch; fakeroot debian/rules binary)

install:
	dpkg -x approx_*.deb $(DESTDIR)
