const std = @import("std");

pub fn LightSwitch(comptime state: anytype) type {
    return struct {
        pub usingnamespace state;

        brightness: f32,

        pub fn print_state(self: @This()) @This() {
            std.debug.print("{s}\t{d:.2}\n", .{ @typeName(state), self.brightness });
            return self;
        }
    };
}

const Off = LightSwitch(light_off);
const On = LightSwitch(light_on);

pub const light_off = struct {
    pub fn new() Off {
        return Off{ .brightness = 0 };
    }

    pub fn turn_on(light_switch: Off) On {
        _ = light_switch;
        return On{ .brightness = 1 };
    }

    pub fn flip(light_switch: Off) On {
        return light_switch.turn_on();
    }
};

pub const light_on = struct {
    pub fn turn_off(light_switch: On) Off {
        _ = light_switch;
        return Off{ .brightness = 0 };
    }

    pub fn flip(light_switch: On) Off {
        return light_switch.turn_off();
    }

    pub fn dim(light_switch: On, level: f32) On {
        _ = light_switch;
        return On{ .brightness = level };
    }
};

test "flip light switch" {
    _ = light_off.new()
        .print_state()
        .flip()
        .print_state()
        .dim(0.5)
        .print_state()
        .turn_off()
        .print_state()
        .turn_on()
        .print_state()
        .flip()
        .print_state()
        // .dim(0.3) // can't dim a light that's off...
        .print_state();
}
