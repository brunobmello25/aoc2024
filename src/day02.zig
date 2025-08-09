const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var safe_count: i32 = 0;
    while (lines.next()) |line| {
        var safe = true;
        var reason: []u8 = undefined;
        var diff: u32 = 0;

        var elems = tokenizeScalar(u8, line, ' ');

        const first = try std.fmt.parseInt(i32, elems.next().?, 10);
        var current = try std.fmt.parseInt(i32, elems.next().?, 10);
        diff = @abs(current - first);
        if (diff < 1 or diff > 3) {
            safe = false;
            reason = try std.fmt.allocPrint(gpa, "Initial difference too large: {}", .{diff});
        }

        const initial_slope = get_slope(first, current);

        while (elems.next()) |elem| {
            const elem_int = try std.fmt.parseInt(i32, elem, 10);
            diff = @abs(elem_int - current);

            if (get_slope(current, elem_int) != initial_slope) {
                safe = false;
                reason = try std.fmt.allocPrint(gpa, "Slope changed from {} to {}", .{ initial_slope, get_slope(current, elem_int) });
            }

            if (diff < 1 or diff > 3) {
                safe = false;
                reason = try std.fmt.allocPrint(gpa, "Difference too large: {}", .{diff});
            }

            current = elem_int;
            if (!safe) break;
        }

        if (safe) {
            safe_count += 1;
            print("Line {s} is safe\n", .{line});
        } else {
            print("Line {s} is unsafe - Reason: {s}\n", .{ line, reason });
        }
    }
    print("Safe count: {}\n", .{safe_count});
}

fn get_slope(a: i32, b: i32) i32 {
    if (a < b) return 1;
    if (a > b) return -1;
    return 0;
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeScalar = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
