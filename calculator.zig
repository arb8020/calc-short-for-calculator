const std = @import("std");

// External functions we'll call from JavaScript
extern fn drawRect(x: f32, y: f32, width: f32, height: f32, r: u8, g: u8, b: u8) void;
extern fn drawText(x: f32, y: f32, ptr: [*]const u8, len: usize) void;
extern fn clearScreen() void;

// State management
var current_number: i32 = 0;
var display_buffer: [32]u8 = undefined;

// Export functions for JavaScript to call
export fn handleKeyPress(key: u8) void {
    if (key >= '0' and key <= '9') {
        const digit = key - '0';
        current_number = current_number * 10 + digit;
    } else if (key == 'c') {  // Clear
        current_number = 0;
    }
    draw();
}

export fn draw() void {
    clearScreen();
    
    // Draw calculator body
    drawRect(10, 10, 300, 400, 200, 200, 200);  // Main background
    drawRect(20, 20, 280, 60, 230, 230, 230);   // Display area
    
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
    
    // Draw zero button
    drawRect(90, 310, 60, 60, 180, 180, 180);
    drawText(115, 345, "0", 1);
    
    // Draw clear button
    drawRect(20, 310, 60, 60, 240, 128, 128);
    drawText(40, 345, "C", 1);
}

// Initialize function
export fn init() void {
    draw();
}
