const std = @import("std");
const sokol = @import("sokol");
const sg = sokol.gfx;

pub const COLOR = struct {r: u8, g: u8, b: u8, a: u8};
pub const BORDER_RADIUS = struct {left: u8, right: u8, top: u8, bottom: u8};
pub const WIDGET_DRAW = struct {faces: u8, instances: u8};

pub const BUFFERS = struct {
    widget_vertex_buffer: ?sg.Buffer,
    widget_index_buffer: ?sg.Buffer,
    widget_draw: ?WIDGET_DRAW,
};

pub const GEOMETRY = struct {
    buffer: BUFFERS,
    
    pub fn init(buffer: BUFFERS) GEOMETRY {
        return .{
            .buffer = buffer,
        };    
    }
    
};


pub const LAYOUT = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
};

pub const STYLE = struct {
    // SEPARA PARA OUTRA ESTRUTURA 'BORDER'
    border_thicknes: ?f32,
    border_color: ?COLOR,
    border_radius: ?BORDER_RADIUS,  
};

pub const WIDGET = struct {
    layout: LAYOUT,
    style: ?STYLE,
    shape: ?GEOMETRY,
    
    
    pub fn init(layout: LAYOUT) WIDGET {

       return .{
         .layout = layout,
         .style = .{
             .border_thicknes = null,
             .border_color = null,
             .border_radius = null,
         },
         .shape = null,
       };
     
       
    }
    
    pub fn set_shape(self: *WIDGET, shape: GEOMETRY) void {
        self.shape = shape;
    }
    
    pub fn set_border_color(self: *WIDGET, border_color: COLOR) void {
        self.style.?.border_color = border_color;
    }
    
    
    pub fn draw(self: *WIDGET) void {
        // CRIAR VALIDAÇÂO if (self.layout.shape){
        
        if (self.shape) |shape| {
            sg.applyBindings(.{
               .vertex_buffers = .{shape.buffer.widget_vertex_buffer.?}**8,
               .index_buffer = shape.buffer.widget_index_buffer.?,
            });

           sg.draw(0, shape.buffer.widget_draw.?.faces, shape.buffer.widget_draw.?.instances);    
        }
    }
};


// STRUCT WIDGETS para renderizar todos os widget