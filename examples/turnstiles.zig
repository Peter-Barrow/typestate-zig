const std = @import("std");

pub fn Turnstile(comptime state: anytype) type {
    return struct {
        coins: u32,
        pub usingnamespace state;

        pub fn init() @This() {
            return .{ .coins = 0 };
        }

        pub fn print(self: @This()) @This() {
            std.debug.print("State:{s}\t|\tHave {d}\n", .{ @typeName(state), self.coins });
            return self;
        }
    };
}

const Locked = Turnstile(locked);
const Unlocked = Turnstile(unlocked);

pub const locked = struct {
    pub fn insert_coin(self: Locked, coins: u32) Unlocked {
        var u = Unlocked.init();
        u.coins = self.coins + coins;
        return u;
    }
};

pub const unlocked = struct {
    pub fn push(self: Unlocked) Locked {
        var l = Locked.init();
        l.coins = self.coins;
        return l;
    }
};

test "turnstile" {
    _ = Locked.init()
        .print()
        .insert_coin(1)
        .print()
        .push()
        .print()
        // .push() // can't push because we have a "locked" state
        .print();
}
