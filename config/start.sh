#!/bin/bash

LOAD_TIMEOUT=100

export QT_QPA_EGLFS_KMS_CONFIG=/etc/qt5/eglfs_kms_cfg.json
export QT_QPA_PLATFORM=eglfs
export QT_QPA_EGLFS_INTEGRATION=none
export TCLLIBPATH=/usr/lib/tcltk/linuxcnc
export LINUXCNC_OPENGL_PLATFORM=egl
export VCP_QML=/usr/share/linuxcnc/vcp.qml

cd /usr/share/linuxcnc
linuxcnc -v ./bone.ini &

while [ $LOAD_TIMEOUT -gt 1 ]; do
		if [ -f /tmp/linuxcnc.lock ]; then
				echo "OK"
				break
		else
				LOAD_TIMEOUT=$((LOAD_TIMEOUT-1))
				sleep .1
		fi
done
