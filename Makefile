# $FreeBSD$

PORTNAME=	texlive-tlptexlive
PORTVERSION=	20120628.20120507
CATEGORIES=	print
MASTER_SITES=	${MASTER_SITE_TEX_CTAN}:ctan \
		http://www.logic.at/people/preining/:tlptexlive
MASTER_SITE_SUBDIR=	systems/texlive/Source:ctan .:tlptexlive
DISTNAME=	texlive-${PORTVERSION:C/\..*//}-source
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}:ctan \
		build-tlptexlive-20120507.zip:tlptexlive

MAINTAINER=	hiroto.kagotani@gmail.com
COMMENT=	Japanized binaries for TeXLive distribution

EXTRACT_DEPENDS=	unzip:${PORTSDIR}/archivers/unzip
BUILD_DEPENDS=	mktexlsr:${PORTSDIR}/print/texlive-core
RUN_DEPENDS=	mktexlsr:${PORTSDIR}/print/texlive-core
LIB_DEPENDS=	fontconfig:${PORTSDIR}/x11-fonts/fontconfig \
		freetype:${PORTSDIR}/print/freetype2 \
		Xaw:${PORTSDIR}/x11-toolkits/libXaw

CFLAGS+=	-fPIC
CONFIGURE_ARGS=	--bindir=${PREFIX}/bin \
		--libdir=${PREFIX}/lib \
		--datadir=${PREFIX}/share \
		--enable-build-in-source-tree \
		--disable-native-texlive-build \
		--with-tex-banner="TeXLive 2012/FreeBSD" \
		--disable-all-pkgs \
		--disable-xdvipdfmx \
		--disable-tex \
		--disable-etex \
		--disable-ptex \
		--disable-eptex \
		--disable-uptex \
		--disable-euptex \
		--disable-aleph \
		--disable-pdftex \
		--disable-luatex \
		--disable-xetex \
		--disable-mf \
		--with-system-freetype2 \
		--with-system-libgs \
		--with-libgs-includes=${LOCALBASE}/include \
		--with-libgs-libdir=${LOCALBASE}/lib \
		--with-system-icu \
		--with-system-libpng \
		--with-system-zlib \
		--with-system-ptexenc \
		--with-ptexenc-includes=${LOCALBASE}/include \
		--with-ptexenc-libdir=${LOCALBASE}/lib \
		--with-system-kpathsea \
		--with-kpathsea-includes=${LOCALBASE}/include \
		--with-kpathsea-libdir=${LOCALBASE}/lib \
		--disable-mp \
		--enable-pmp \
		--enable-pxdvik \
		--enable-web2c

GNU_CONFIGURE=	yes
MAKE_ARGS+=	GNUMAKE="${GMAKE}" ARCH="arch/unix"
USE_GMAKE=	yes
USE_PERL5=	yes
USE_XLIB=	yes
USE_XZ=		yes
USE_AUTOTOOLS=	autoconf

post-extract:
	cd ${WRKDIR}; ${UNZIP_CMD} -q ${DISTDIR}/build-tlptexlive-latest.zip

pre-patch:
	cd ${WRKSRC}; ${CP} -pR texk/xdvik texk/pxdvik
	cd ${WRKSRC}; ${PATCH} -d texk/pxdvik -p1 < ${WRKDIR}/build-tlptexlive/xdvik-20120415-texlive2011.diff
	cd ${WRKSRC}; ${PATCH} -d texk/pxdvik -p1 < ${WRKDIR}/build-tlptexlive/pxdvik-20111126-density.diff
	cd ${WRKSRC}; ${PATCH} -d texk/pxdvik -p1 < ${WRKDIR}/build-tlptexlive/pxdvik-20111212-uptex.diff
	cd ${WRKSRC}; ${REINPLACE_CMD} -E 's/# (AUX_MODULES \+= otvalid)/\1/' libs/freetype2/freetype-2.4.9/modules.cfg
	cd ${WRKSRC}; s=`${ECHO_CMD} 's/xdvik/xdvik\\'; ${ECHO_CMD} pxdvik/`; ${REINPLACE_CMD} -e "$$s" m4/kpse-pkgs.m4

	cd ${WRKSRC}; ${PATCH} -d texk -p0 < ${WRKDIR}/build-tlptexlive/pmpost-20120415-tl11.diff
	cd ${WRKSRC}; ${PATCH} -d texk -p0 < ${WRKDIR}/build-tlptexlive/pmpost-svg-20120119-tl11.diff
	cd ${WRKSRC}; ${REINPLACE_CMD} 's/ (TeX Live 2012)/" WEB2CVERSION "/' texk/web2c/pmplibdir/pmpost.ch

	@${FIND} ${WRKSRC} -name 'Makefile.in' | ${XARGS} ${SED} -EI '' \
	    -e 's,(\$$[{(]prefix[)}])/(texmf|\$$[{(]scriptsdir[)}]),\1/share/\2,'
	@${REINPLACE_CMD} 's/\$$(REL)\/texmf\//\$$(REL)\/share\/texmf\//g' ${WRKSRC}/texk/texlive/linked_scripts/Makefile.in
	@${REINPLACE_CMD} 's/\$$(REL)\/texmf-dist\//\$$(REL)\/share\/texmf-dist\//g' ${WRKSRC}/texk/texlive/linked_scripts/Makefile.in

post-patch:
	cd ${WRKSRC}/texk; ${AUTORECONF} --no-recursive
	cd ${WRKSRC}/texk/pxdvik; ${AUTORECONF} --no-recursive
	cd ${WRKSRC}/texk/web2c; ${AUTORECONF} --no-recursive
	${REINPLACE_CMD} -E -e 's,(\$$[{(]prefix[)}])/(texmf|\$$[{(]scriptsdir[)}]),\1/share/\2,' ${WRKSRC}/texk/pxdvik/Makefile.in

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/texk/pxdvik/xdvi-bin ${PREFIX}/bin/pxdvi-xaw
	${INSTALL_SCRIPT} ${WRKSRC}/texk/pxdvik/xdvi ${PREFIX}/bin/pxdvi
#	${INSTALL_DATA} ${WRKSRC}/texk/pxdvik/texmf/XDvi ${PREFIX}/share/texmf/xdvi
	${MKDIR} ${PREFIX}/share/texmf/xdvi
	${INSTALL_DATA} ${WRKSRC}/texk/pxdvik/texmf/pxdvi.cfg ${PREFIX}/share/texmf/xdvi
	${INSTALL_DATA} ${WRKSRC}/texk/pxdvik/xdvi-ptex.sample ${PREFIX}/share/texmf/xdvi

post-install:
	@${LN} -sf pmpost ${PREFIX}/bin/pdvitomp
	@${LN} -sf eptex ${PREFIX}/bin/platex
	@${LN} -sf euptex ${PREFIX}/bin/uplatex
.if defined(WITHOUT_TEXLIVE_MKTEXLSR)
	@${ECHO_CMD} "WITHOUT_TEXLIVE_MKTEXLSR is set.  Not running mktexlsr."
	@${ECHO_CMD} "You MUST run 'mktexlsr' to update TeXLive installed files database."
.else
	@${ECHO_CMD} "Updating ls-R databases..."
	@${LOCALBASE}/bin/mktexlsr
.endif

.include <bsd.port.mk>
