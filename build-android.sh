#!/usr/bin/env bash
# Build the Android APK (and optionally install + launch it on a connected device).
#
# Usage: ./build-android.sh [--install]
#
# Requires Gluon's GraalVM 22.1 (Java 17). gluonfx/substrate's default static JDK
# (18-ea+prep18-9) only matches GraalVM 22.1; GraalVM 23 fails in native-image.
set -euo pipefail
cd "$(dirname "$0")"

export GRAALVM_HOME="${GRAALVM_HOME:-$HOME/.local/opt/graalvm-gluon22}"
export JAVA_HOME="$GRAALVM_HOME"
export ANDROID_SDK="${ANDROID_SDK:-$HOME/.gluon/substrate/Android}"
# JDK 17.0.3 crashes on cgroup v2-only hosts without this.
export _JAVA_OPTIONS="${_JAVA_OPTIONS:-} -XX:-UseContainerSupport"
unset ANDROID_HOME

mvn -B -Pandroid gluonfx:build gluonfx:package

APK=target/gluonfx/aarch64-android/gvm/client.apk
echo "APK: $APK"

if [[ "${1:-}" == "--install" ]]; then
    adb install -r "$APK"
    adb shell monkey -p com.streampi.client -c android.intent.category.LAUNCHER 1 >/dev/null
fi
