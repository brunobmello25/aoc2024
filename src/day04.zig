const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");

const print = std.debug.print;

const Coord = struct {
    x: isize,
    y: isize,
};

const Matrix = []const []const u8;

pub fn main() !void {
    const matrix = try data_to_matrix();

    const result = try run(matrix);
    print("Found {d} targets in the matrix.\n", .{result});
}

fn run(matrix: Matrix) !usize {
    var found_count: usize = 0;

    for (matrix, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == 'X') {
                const directions = [_][]const u8{
                    "up",      "down",     "left",      "right",
                    "up-left", "up-right", "down-left", "down-right",
                };
                for (directions) |direction| {
                    const coord = Coord{ .x = @intCast(x), .y = @intCast(y) };
                    const current_word: []u8 = "";
                    const target = search(matrix, coord, direction, current_word);
                    if (target) |found_target| {
                        found_count += 1;
                        print("Found target at ({d}, {d}) ({c}) in direction '{s}'\n", .{ found_target.x, found_target.y, matrix[@intCast(found_target.y)][@intCast(found_target.x)], direction });
                    }
                }
            }
        }
    }

    return found_count;
}

fn data_to_matrix() ![][]const u8 {
    var rows = std.ArrayList([]const u8).init(gpa);

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (line.len == 0) continue;

        try rows.append(line);
    }

    return rows.items;
}

fn search(matrix: Matrix, current_coord: Coord, direction: []const u8, current_word: []const u8) ?Coord {
    if (std.mem.eql(u8, current_word, "XMAS")) {
        return current_coord;
    }

    const x = current_coord.x;
    const y = current_coord.y;

    const new_char = matrix[@intCast(y)][@intCast(x)];
    const new_word = std.fmt.allocPrint(gpa, "{s}{c}", .{ current_word, new_char }) catch return null;
    defer gpa.free(current_word);

    const next_coord = get_coord_at_direction(matrix, current_coord, direction);
    if (next_coord == null) return null;

    return search(matrix, next_coord.?, direction, new_word);
}

fn get_next_target(current_target: u8) ?u8 {
    if (current_target == 'X') return 'M';
    if (current_target == 'M') return 'A';
    if (current_target == 'A') return 'S';
    return null;
}

fn get_coord_at_direction(matrix: Matrix, current: Coord, dir: []const u8) ?Coord {
    var direction: Coord = undefined;
    if (std.mem.eql(u8, dir, "up")) {
        direction = Coord{ .x = 0, .y = -1 };
    } else if (std.mem.eql(u8, dir, "down")) {
        direction = Coord{ .x = 0, .y = 1 };
    } else if (std.mem.eql(u8, dir, "left")) {
        direction = Coord{ .x = -1, .y = 0 };
    } else if (std.mem.eql(u8, dir, "right")) {
        direction = Coord{ .x = 1, .y = 0 };
    } else if (std.mem.eql(u8, dir, "up-left")) {
        direction = Coord{ .x = -1, .y = -1 };
    } else if (std.mem.eql(u8, dir, "up-right")) {
        direction = Coord{ .x = 1, .y = -1 };
    } else if (std.mem.eql(u8, dir, "down-left")) {
        direction = Coord{ .x = -1, .y = 1 };
    } else if (std.mem.eql(u8, dir, "down-right")) {
        direction = Coord{ .x = 1, .y = 1 };
    } else {
        return null; // Invalid direction
    }

    const x = current.x + direction.x;
    const y = current.y + direction.y;

    if (y < 0 or y >= matrix.len) {
        return null;
    }
    if (x < 0 or x >= matrix[@intCast(y)].len) {
        return null;
    }

    return Coord{
        .x = x,
        .y = y,
    };
}

test "get coord for direction" {
    const rawData = [_][]const u8{
        "123",
        "456",
        "789",
    };
    // slicing it gives you a [][]const u8
    const testdata: Matrix = &rawData;

    var current = Coord{ .x = 1, .y = 1 };

    const up_coord = get_coord_at_direction(testdata, current, "up");
    try std.testing.expectEqual(Coord{ .x = 1, .y = 0 }, up_coord.?);
    var down_coord = get_coord_at_direction(testdata, current, "down");
    try std.testing.expectEqual(Coord{ .x = 1, .y = 2 }, down_coord.?);
    const left_coord = get_coord_at_direction(testdata, current, "left");
    try std.testing.expectEqual(Coord{ .x = 0, .y = 1 }, left_coord.?);
    var right_coord = get_coord_at_direction(testdata, current, "right");
    try std.testing.expectEqual(Coord{ .x = 2, .y = 1 }, right_coord.?);

    current = Coord{ .x = 0, .y = 0 };

    const up_coord_invalid = get_coord_at_direction(testdata, current, "up");
    try std.testing.expect(up_coord_invalid == null);
    const left_coord_invalid = get_coord_at_direction(testdata, current, "left");
    try std.testing.expect(left_coord_invalid == null);
    down_coord = get_coord_at_direction(testdata, current, "down");
    try std.testing.expectEqual(Coord{ .x = 0, .y = 1 }, down_coord.?);
    right_coord = get_coord_at_direction(testdata, current, "right");
    try std.testing.expectEqual(Coord{ .x = 1, .y = 0 }, right_coord.?);

    // test diagonals
    current = Coord{ .x = 1, .y = 1 };
    const up_left_coord = get_coord_at_direction(testdata, current, "up-left");
    try std.testing.expectEqual(Coord{ .x = 0, .y = 0 }, up_left_coord.?);
    const up_right_coord = get_coord_at_direction(testdata, current, "up-right");
    try std.testing.expectEqual(Coord{ .x = 2, .y = 0 }, up_right_coord.?);
    const down_left_coord = get_coord_at_direction(testdata, current, "down-left");
    try std.testing.expectEqual(Coord{ .x = 0, .y = 2 }, down_left_coord.?);
    var down_right_coord = get_coord_at_direction(testdata, current, "down-right");
    try std.testing.expectEqual(Coord{ .x = 2, .y = 2 }, down_right_coord.?);

    // test invalid diagonals
    current = Coord{ .x = 0, .y = 0 };
    const up_left_coord_invalid = get_coord_at_direction(testdata, current, "up-left");
    try std.testing.expect(up_left_coord_invalid == null);
    const up_right_coord_invalid = get_coord_at_direction(testdata, current, "up-right");
    try std.testing.expect(up_right_coord_invalid == null);
    const down_left_coord_invalid = get_coord_at_direction(testdata, current, "down-left");
    try std.testing.expect(down_left_coord_invalid == null);
    down_right_coord = get_coord_at_direction(testdata, current, "down-right");
    try std.testing.expectEqual(Coord{ .x = 1, .y = 1 }, down_right_coord.?);
}

fn concat_example(banana: *[]u8) void {
    banana = std.mem.concat(u8, banana.*, "a");
}
