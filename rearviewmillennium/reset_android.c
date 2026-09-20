#include <jni.h>
#include "RearviewMillennium.h"

/*
 * Android JNI wrapper
 */
JNIEXPORT void JNICALL
Java_com_paralevels_rearviewmillennium_MainActivity_exitResetCurr(
        JNIEnv *env,
        jobject thiz,
        jstring base_dir_j)
{
    // Converts Java/Kotlin baseDir string to a C string
    const char *base_dir =
            (*env)->GetStringUTFChars(env, base_dir_j, 0);

    if (!base_dir)
        return;

    // Calls platform-independent reset function
    exit_reset_curr(base_dir);

    // Releases Java/Kotlin baseDir string
    (*env)->ReleaseStringUTFChars(env, base_dir_j, base_dir);
}
