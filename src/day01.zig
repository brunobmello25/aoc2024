const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");

pub fn main() !void {
    var lines = splitAny(u8, data, "\n");

    var left = std.ArrayList(isize).init(gpa);
    var right = std.ArrayList(isize).init(gpa);

    while (lines.next()) |line| {
        if (line.len == 0) continue; // Skip empty lines

        var parts = tokenizeAny(u8, line, " \t");

        const leftpart = parts.next() orelse {
            print("No left part found\n", .{});
            continue;
        };
        const rightpart = parts.next() orelse {
            print("No right part found\n", .{});
            continue;
        };

        const leftparsed = try parseInt(isize, leftpart, 10);
        const rightparsed = try parseInt(isize, rightpart, 10);

        try left.append(leftparsed);
        try right.append(rightparsed);
    }

    std.mem.sort(isize, left.items, {}, std.sort.asc(isize));
    std.mem.sort(isize, right.items, {}, std.sort.asc(isize));

    var total: isize = 0;
    for (left.items, right.items) |l, r| {
        const dist: isize = @intCast(@abs(l - r));
        total += dist;
    }

    print("Total distance: {}\n", .{total});
}
// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
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
