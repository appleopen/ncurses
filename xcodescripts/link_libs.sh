#!/bin/sh

ver=5.4

# check if we're building for the simulator
if [ "${RC_ProjectName%_Sim}" != "${RC_ProjectName}" ] ; then
	DSTROOT="${DSTROOT}${SDKROOT}"
	[ -n "${RC_TARGET_CONFIG}" ] || RC_TARGET_CONFIG="iPhone"

	for lib in libform.${ver}.dylib libmenu.${ver}.dylib libncurses.${ver}.dylib libpanel.${ver}.dylib ; do
		install_name_tool -id /usr/lib/${lib} ${DSTROOT}/usr/lib/${lib}
		for lib2 in libform.${ver}.dylib libmenu.${ver}.dylib libncurses.${ver}.dylib libpanel.${ver}.dylib ; do
			install_name_tool -change ${SDKROOT}/usr/lib/${lib} /usr/lib/${lib} ${DSTROOT}/usr/lib/${lib2}
		done
	done
fi

# Assume MacOSX if RC_TARGET_CONFIG isn't set
[ -n "${RC_TARGET_CONFIG}" ] || RC_TARGET_CONFIG="MacOSX"

for link in libform.dylib libmenu.dylib libncurses.dylib libpanel.dylib ; do
	ln -s $(basename -s .dylib $link).${ver}.dylib "$DSTROOT/usr/lib/$link"
done

for link in libcurses.dylib libtermcap.dylib ; do
	ln -s libncurses.${ver}.dylib $DSTROOT/usr/lib/$link
done

if [ "${RC_TARGET_CONFIG}" == "MacOSX" ] ; then
	# libncurses.5.dylib -- install the tiger version if i386 or ppc is a target arch
	if echo $ARCHS | grep -qE "ppc|i386"; then
		bzcat libncurses.5.dylib.tar.bz2 | (cd $DSTROOT; tar xf -)
	fi
fi