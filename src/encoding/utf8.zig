const std = @import("std");
const Allocator = std.mem.Allocator;
const EncoderHandler = @import("../encode.zig").EncoderHandler;
const HandlerResult = @import("../encode.zig").HandlerResult;

const IoQueue = @import("../io_queue.zig").IoQueue;

// https://encoding.spec.whatwg.org/#utf-8-encoder
pub const Utf8EncoderHandler = struct {
    allocator: *Allocator,
    handler: EncoderHandler = EncoderHandler{
        .handleFn = handle,
        .deinitFn = deinit,
    },

    pub fn init(allocator: *Allocator) !*Utf8EncoderHandler {
        var handler = try allocator.create(Utf8EncoderHandler);
        handler.* = Utf8EncoderHandler{ .allocator = allocator };
        return handler;
    }

    fn deinit(self: *EncoderHandler) void {
        var utf8EncoderHandler: *Utf8EncoderHandler = @fieldParentPtr(Utf8EncoderHandler, "handler", self);
        utf8EncoderHandler.allocator.destroy(utf8EncoderHandler);
    }

    fn handle(self: *EncoderHandler, item: IoQueue(u21).Item) !HandlerResult {
        var utf8_encoder_handler = @fieldParentPtr(Utf8EncoderHandler, "handler", self);
        var alloc = utf8_encoder_handler.allocator;
        switch (item) {
            .EndOfQueue => {
                return .Finished;
            },
            .Regular => |code_point| {
                var bytes: []u8 = try alloc.alloc(u8, 1);
                bytes[0] = @intCast(u8, item.Regular);
                return HandlerResult{
                    .Items = bytes,
                };
            },
        }
    }
};
