#include "RearviewMillennium.h"

// iOS / Swift wrapper
char *genscene_ios(const char *base_dir, int choice)
{
    // Calls platform-independent game engine
    return genscene(base_dir, choice);
}
