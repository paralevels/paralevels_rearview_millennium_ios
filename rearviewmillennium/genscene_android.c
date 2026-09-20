#include <jni.h>
#include "RearviewMillennium.h"

// Android JNI wrapper
JNIEXPORT jstring JNICALL
Java_com_paralevels_rearviewmillennium_MainActivity_genscene(
        JNIEnv *env,
        jobject thiz,
        jstring base_dir_j,
        jint choice)
{
    // Converts Java/Kotlin baseDir string to a C string
    const char *base_dir =
            (*env)->GetStringUTFChars(env, base_dir_j, 0);

    // No base_dir. Returns error message.
    if (!base_dir)
        return (*env)->NewStringUTF(
                env,
                "ERROR\n\nBase directory missing.\n\nContinue\n\nContinue\n");

    // Calls platform-independent game engine
    char *buffer = genscene(base_dir, choice);

    // Releases Java/Kotlin baseDir string
    (*env)->ReleaseStringUTFChars(env, base_dir_j, base_dir);

    // Handles out-of-memory error
    if (!buffer)
        return (*env)->NewStringUTF(
                env,
                "ERROR\n\nOut of memory.\n\nContinue\n\nContinue\n");

    // Converts C buffer to Java/Kotlin string
    jstring result = (*env)->NewStringUTF(env, buffer);

    // Frees memory
    free(buffer);

    // Returns scene string to Kotlin/Java
    return result;
}
