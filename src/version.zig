const VERSION_MAJOR = 0;
const VERSION_MINOR = 2;
const VERSION_PATCH = 0;

pub fn get(major: *u32, minor: *u32, patch: *u32) void
{
    major.* = VERSION_MAJOR;
    minor.* = VERSION_MINOR;
    patch.* = VERSION_PATCH;
}
