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
    
    pub fn BUTTON_SHAPE() GEOMETRY {
       const my_vertex_buffer = sg.makeBuffer(.{
          .usage = .{
          .vertex_buffer = true,
          },
    
       .data = sg.asRange(&[_]f32{
            -0.5, 0.5,  0.5, 1.0, 0.0, 0.0, 1.0, 0,
            0.5,  0.5,  0.5, 0.0, 1.0, 0.0, 1.0, 0,
            0.5,  -0.5, 0.5, 0.0, 0.0, 1.0, 1.0, 0,
            -0.5, -0.5, 0.5, 1.0, 1.0, 0.0, 1.0, 0,   
       }),
     });
        
        const my_index_buffer = sg.makeBuffer(.{
            .usage = .{ .index_buffer = true },
            .data = sg.asRange(&[_]u16{ 
                0, 1, 2, 
                0, 2, 3,
            }),
        });

        
        return .{
            .buffer = .{
                .widget_vertex_buffer = my_vertex_buffer, 
                .widget_index_buffer = my_index_buffer,
                .widget_draw = .{.faces = 6, .instances = 1}, 
            }       
        };
    }
    // CRIAR UMA PRONTAS
    
};

// FAZER UM CALLBACK NAS ESTRUTURAS PARA QUANDO CHAMMAR PODE ENCADEAR
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
    layout: ?LAYOUT,
    style: ?STYLE,
    shape: ?GEOMETRY,
    next: ?*WIDGET = null,
    prev: ?*WIDGET = null,
    
    pub fn init(layout: *LAYOUT, shape: GEOMETRY) WIDGET {

       return .{
         .layout = *layout,
         .style = .{
             .border_thicknes = null,
             .border_color = null,
             .border_radius = null,
         },
         .shape = shape,
       };
     
       
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


// CRIAR UMA VARIAVEL QUE SERA WIDGETS.INIT, QUE RECEBERA UM WIDGETS, E PODERIA IMPORTAR APENAS ESSA VARIAVEL
// SENDO  QUE AI PODERIA PUXAR O WIDGETS.BUTTON() E CRIAR UM NOVO BOTÂO DIFERENTE
// BASICAMENTE WIDGETS SERA UM OBJECTO STATICO E BUTTON(WIDGET) PODE TER VARIOS OBJETOS

pub var WIDGETS = WIDGETS_{ .head = null, .geometrys = null };

pub const WIDGETS_ = struct {
    head: ?*WIDGET, 
    geometrys: ?GEOMETRY,
    
    pub fn init_variable() void {
       WIDGETS = WIDGETS_.init();
    }
    
    pub fn init() WIDGETS_ {
       const dafault_geometrys = GEOMETRY.BUTTON_SHAPE();       
       var default_head = WIDGET{.layout = null, .style = null, .shape = null};
       
       return .{
            .head = &default_head,
            .geometrys = dafault_geometrys,
       };
    }

    pub fn insert_widget(self: *WIDGETS_, widget: *WIDGET) void {
        if (self.head == null) {
            
            self.head = widget;
            self.head.?.prev = widget;
            self.head.?.next = widget;
            
          
            return;
            
        }
    
        widget.prev = self.head.?.prev;
        self.head.?.prev.?.next = widget;
        self.head.?.prev = widget;
    }
    
    
    
    
    pub fn BUTTON(self: *WIDGETS_) *WIDGET {
        var btt: WIDGET = .{
            .layout = null,
            .style = .{ 
                .border_color = .{ .r = 0.0, .g = 0.0, .b = 0.0, .a = 50.0 },
                .border_thicknes = 20.0,
                .border_radius = null,
            },
            .shape = self.geometrys,
        };
        
        WIDGETS.insert_widget(&btt);
        return &btt;
    }
    
    pub fn draw(self: *WIDGETS_) void {
        if (self.head) |atual_| {
           
           if (atual_.style) |atual_style| {
                std.debug.print("RGB: {?}", .{atual_style.border_thicknes});           
           }
           
           self.head = atual_.next;
        }
        
    }
};


