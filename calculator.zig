const std = @import("std");

// External functions we'll call from JavaScript
extern fn drawRect(x: f32, y: f32, width: f32, height: f32, r: u8, g: u8, b: u8) void;
extern fn drawText(x: f32, y: f32, ptr: [*]const u8, len: usize) void;
extern fn clearScreen() void;

// Calculator state
const Operation = enum {
    None,
    Add,
    Subtract,
    Multiply,
    Divide,
};

var current_number: i32 = 0;
var stored_number: i32 = 0;
var current_operation: Operation = .None;
var display_buffer: [32]u8 = undefined;
var show_result: bool = false;

// Export functions for JavaScript to call
export fn handleKeyPress(key: u8) void {
    if (show_result) {
        current_number = 0;
        show_result = false;
    }

    switch (key) {
        '0'...'9' => {
            const digit = key - '0';
            current_number = current_number * 10 + digit;
        },
        'c' => {  // Clear
            current_number = 0;
            stored_number = 0;
            current_operation = .None;
            show_result = false;
        },
        '+' => {
            stored_number = current_number;
            current_number = 0;
            current_operation = .Add;
        },
        '-' => {
            stored_number = current_number;
            current_number = 0;
            current_operation = .Subtract;
        },
        '*' => {
            stored_number = current_number;
            current_number = 0;
            current_operation = .Multiply;
        },
        '/' => {
            stored_number = current_number;
            current_number = 0;
            current_operation = .Divide;
        },
        '=' => calculate(),
        else => {},
    }
    draw();
}

fn calculate() void {
    const result = switch (current_operation) {
        .Add => stored_number + current_number,
        .Subtract => stored_number - current_number,
        .Multiply => stored_number * current_number,
        .Divide => if (current_number != 0) @divTrunc(stored_number, current_number) else 0,
        .None => current_number,
    };
    current_number = result;
    show_result = true;
    current_operation = .None;
}

export fn draw() void {
    clearScreen();
    
    // Draw calculator body
    drawRect(10, 10, 300, 400, 200, 200, 200);  // Main background
    drawRect(20, 20, 280, 60, 230, 230, 230);   // Display area
    
    // Draw current operation indicator
    const op_str = switch (current_operation) {
        .Add => "+",
        .Subtract => "-",
        .Multiply => "*",
        .Divide => "/",
        .None => "",
    };
    if (op_str.len > 0) {
        drawText(280, 50, op_str.ptr, op_str.len);
    }

    // Draw number display
    const display = std.fmt.bufPrint(&display_buffer, "{d}", .{current_number}) catch return;
    drawText(30, 50, display.ptr, display.len);
    
    // Draw number buttons
    var row: usize = 0;
    var col: usize = 0;
    var i: u8 = 1;
    while (i <= 9) : (i += 1) {
        const x: f32 = @floatFromInt(20 + col * 70);
        const y: f32 = @floatFromInt(100 + row * 70);
        drawRect(x, y, 60, 60, 180, 180, 180);  // Button background
        
        const num_str = std.fmt.bufPrint(&display_buffer, "{d}", .{i}) catch return;
        drawText(x + 25, y + 35, num_str.ptr, num_str.len);
        
        col += 1;
        if (col == 3) {
            col = 0;
            row += 1;
        }
    }
    
    // Draw operation buttons (right column)
    const operations = [_][]const u8{ "+", "-", "*", "/" };
    for (operations, 0..) |op, idx| {
        const y: f32 = @floatFromInt(100 + idx * 70);
        drawRect(230, y, 60, 60, 160, 160, 200);  // Operation button
        drawText(250, y + 35, op.ptr, op.len);
    }
    
    // Draw zero button
    drawRect(90, 310, 60, 60, 180, 180, 180);
    drawText(115, 345, "0", 1);
    
    // Draw clear button
    drawRect(20, 310, 60, 60, 240, 128, 128);
    drawText(40, 345, "C", 1);

    // Draw equals button
    drawRect(230, 310, 60, 60, 128, 240, 128);
    drawText(250, 345, "=", 1);
}

// Initialize function
export fn init() void {
    draw();
}
