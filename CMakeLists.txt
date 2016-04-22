project(WeiXin)
cmake_minimum_required (VERSION 2.8)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)

#
# Base bits
#
set (CMAKE_C_FLAGS "-ggdb")
set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")
set (PKGDATADIR "${DATADIR}/weixin")
set (GETTEXT_PACKAGE "weixin")
set (RELEASE_NAME "WeiXin")
set (VERSION "1.0")
set (VERSION_INFO "Release")


#
# Niceties
#
set (ARCHIVE_NAME weixin-${VERSION})
add_custom_target (dist
    COMMAND bzr export --root=${ARCHIVE_NAME} ${CMAKE_BINARY_DIR}/${ARCHIVE_NAME}.tar.bz2
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

add_custom_target (distcheck
    COMMAND cd ${CMAKE_BINARY_DIR}
    && rm -rf ${ARCHIVE_NAME}
    && tar xf ${ARCHIVE_NAME}.tar.bz2
    && mkdir ${ARCHIVE_NAME}/build
    && cd ${ARCHIVE_NAME}/build
    && cmake -DCMAKE_INSTALL_PREFIX=../install -DGSETTINGS_LOCALINSTALL=ON .. -DCMAKE_MODULE_PATH=/usr/share/cmake
    && make -j8
    && make -j8 install
    && make check
    )
add_dependencies(distcheck dist)

add_custom_target (uninstall "${CMAKE_COMMAND}" -P
  "${CMAKE_SOURCE_DIR}/cmake/uninstall.cmake")


#
# config.h
#

configure_file (${CMAKE_SOURCE_DIR}/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)
add_definitions(-include config.h)


#
# Data
#

file (GLOB _datafiles "${CMAKE_CURRENT_SOURCE_DIR}/data/files/*")
install (FILES ${_datafiles} DESTINATION ${PKGDATADIR}/files)

file (GLOB _imagefiles "${CMAKE_CURRENT_SOURCE_DIR}/data/icons/*")
install (FILES ${_imagefiles} DESTINATION ${PKGDATADIR})

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/weixin.desktop DESTINATION /usr/share/applications)

#
# Icons
#

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/weixin.png DESTINATION share/icons/hicolor/scalable/apps/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/indicator-weixin.png DESTINATION share/icons/hicolor/scalable/status/)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/icons/indicator-weixin-new.png DESTINATION share/icons/hicolor/scalable/status/)

option (ICON_UPDATE "Run gtk-update-icon-cache after the install." ON)
if (ICON_UPDATE)
  install (CODE "message(\"-- Updating icon cache...\")")
  install (CODE "execute_process(COMMAND gtk-update-icon-cache -f -t ${CMAKE_INSTALL_PREFIX}/share/icons/hicolor)")
endif ()


#
# SRC
#

find_package(PkgConfig)
pkg_check_modules(DEPS REQUIRED gobject-2.0 glib-2.0 gio-2.0 gtk+-3.0>=3.12 webkit2gtk-4.0 appindicator3-0.1)

add_definitions(${DEPS_CFLAGS})

link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.26.0" MINIMUM)

set(PKG_DEPS gtk+-3.0
             gio-2.0
             gee-0.8
             webkit2gtk-4.0
             appindicator3-0.1)


set(SRC_FILES
            src/WebApp.vala
            src/WeiXin.vala
            src/WebAppWindow.vala)



include(ValaPrecompile)
vala_precompile(VALA_C ${SRC_FILES} PACKAGES ${PKG_DEPS}

OPTIONS
    -g
    --debug
    --target-glib=2.32
    )

add_definitions(${CFLAGS}-lm -Wall -Winit-self -Wwrite-strings -Wunreachable-code -Wstrict-prototypes)
add_executable(weixin ${VALA_C})
target_link_libraries(weixin ${SQLITE_LIBRARIES} ${CLUTTERGTK_LIBRARIES} -lm)
install(TARGETS weixin RUNTIME DESTINATION bin)
