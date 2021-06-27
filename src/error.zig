pub const ErrorMode = enum {
    Replacement,
    Html,
    Fatal,
};

pub const WebEncError = error{
    RangeError,
};
