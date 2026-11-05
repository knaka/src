#include <CoreGraphics/CoreGraphics.h>

int main() {
    return CGDisplayIsAsleep(CGMainDisplayID());
}
