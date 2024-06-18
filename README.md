# Typestate pattern in Zig

> A small example to see if the typestate pattern can be realised in Zig

For a thorough explanation of the typestate pattern head over to <http://cliffle.com/blog/rust-typestate/>.


## What is the typestate pattern?

Typestate is a pattern more commonly seen in languages with rich type systems like Rust and Swift, allowing the use of generics to define specific states and the allowed state transistions between them, like state machines for types.
Simply, the typestate pattern is a method to encode information about the state of a variable during runtime with its type at compile time.


## How about Zig?


## Examples
The code for the following examples can be found in the examples folder.

### Light switches
Implementing the example from [No Boilerplate](https://www.youtube.com/watch?v=Kdpfhj3VM04)

First we need to make a type that can be specialised at compile time.
```zig
pub fn LightSwitch(comptime state: anytype) type {
    return struct {
        pub usingnamespace state;

        brightness: f32,
    };
}
```
We'll make use of the ```usingnamespace``` keyword so that we can treat our implementations as mixins and only have the specified functionality for each case.
Next, lets define our ```Off``` and ```On``` states:
```zig
const Off = LightSwitch(light_off);
const On = LightSwitch(light_on);
```

Finally we can specifiy our implementations for the on and off states.
```zig
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
```

Now we can:
    - make a new light
    - flip the switch to turn it on
    - dim the light
    - and finally turn it off

```zig
test "flip light switch" {
    _ = light_off.new()
        .flip()
        .dim(0.5)
        .turn_off()
}
```

And if we try to:
    - make a new light
    - flip the switch to turn it on
    - dim the light
    - turn it on (again)

```zig
test "flip light switch" {
    _ = light_off.new()
        .flip()
        .dim(0.5)
        .turn_on()
}
```
We get the following compilation error

```
examples/lightswitch.zig:57:9: error: no field or member functio
n named 'turn_on' in 'lightswitch.LightSwitch(lightswitch.light_
on)'
        .turn_on();
        ^~~~~~~~
examples/lightswitch.zig:4:12: note: struct declared here
    return struct {
           ^~~~~~
```

### Turnstiles
Implementing the example from [Swiftology](https://swiftology.io/articles/typestate/)

Similarly to the lightswitch examples we need a type that can be parameterised, in Zig this takes the form of a comptime function that returns a type.

```zig
pub fn Turnstyle(comptime state: anytype) type {
    return struct {
        coins: u32,
        pub usingnamespace state;

        pub fn init() @This() {
            return .{ .coins = 0 };
        }
    };
}

```

Next, define the allowed states:

```zig
const Locked = Turnstyle(locked);
const Unlocked = Turnstyle(unlocked);
```

The the implementations, a turnstile can only go from locked to unlocked if coins are added, conversely it can only go from unlocked to locked by pushing it open and walking through.
```zig
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
```

Here is the correct usage of the turnstile:
```zig
test "turnstile" {
    _ = Locked.init()
        .insert_coin(1)
        .push();
}
```

And now if we try the following:
```zig
test "turnstile" {
    _ = Locked.init()
        .insert_coin(1)
        .insert_coin(1)
        .push();
}
```

We get the following compile error as we can't insert coins into an unlocked turnstile.
```
examples/turnstiles.zig:42:9: error: no field or member function
 named 'insert_coin' in 'turnstiles.Turnstile(turnstiles.unlocke
d)'
        .insert_coin(1)
        ^~~~~~~~~~~~
examples/turnstiles.zig:4:12: note: struct declared here
    return struct {
           ^~~~~~
```
