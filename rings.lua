local config = {
    -- bg_color = 0x11ffff,
    bg_color = 0x450eff,
    bg_alpha = 0.5,
    fg_color = 0x08f7fe,
    fg_alpha = 0.8
}
local elements = {

    {x0 = 10, y0 = 200, x1 = 327, y1 = 200, width = 2}, {
        name = 'memperc',
        arg = '',
        max = 100,
        x = 370,
        y = 200,
        r = 40,
        width = 6,
        start_angle = -90,
        end_angle = 180
    }, -- Line for CPU process
    {x0 = 10, y0 = 300, x1 = 327, y1 = 300, width = 2}, {
        name = 'cpu',
        arg = '',
        max = 100,
        x = 370,
        y = 300,
        r = 40,
        width = 6,
        start_angle = -90,
        end_angle = 180
    }, {
        name = 'acpitemp',
        arg = '',
        max = 100,
        x = 370,
        y = 300,
        r = 30,
        width = 6,
        start_angle = -90,
        end_angle = 180
    }
}
require 'cairo'

function rgba(color, alpha)
    return color / 0x10000 % 0x100 / 255., color / 0x100 % 0x100 / 255.,
           color % 0x100 / 255., alpha
end

function draw_line(cr, pt)
    cairo_move_to(cr, pt['x0'], pt['y0'])
    cairo_line_to(cr, pt['x1'], pt['y1'])
    cairo_set_source_rgba(cr, rgba(config['fg_color'], config['fg_alpha']))
    cairo_set_line_width(cr, pt['width'])
    cairo_stroke(cr)
end

function draw_ring(cr, val, pt)
    local angle_0 = pt['start_angle'] * math.pi / 180 - math.pi / 2
    local angle_f = pt['end_angle'] * math.pi / 180 - math.pi / 2
    local angle_t = angle_0 + val / pt['max'] * (angle_f - angle_0)
    cairo_arc(cr, pt['x'], pt['y'], pt['r'], angle_0, angle_f)
    cairo_set_source_rgba(cr, rgba(config['bg_color'], config['bg_alpha']))
    cairo_set_line_width(cr, pt['width'])
    cairo_stroke(cr)
    cairo_arc(cr, pt['x'], pt['y'], pt['r'], angle_0, angle_t)
    cairo_set_source_rgba(cr, rgba(config['fg_color'], config['fg_alpha']))
    cairo_stroke(cr)
end

function setup_rings(cr, pt)
    if pt['name'] == nil then
        draw_line(cr, pt)
    else
        local val =
            conky_parse(string.format('${%s %s}', pt['name'], pt['arg'])):gsub(
                '%%', '')
        val = tonumber(val)
        if val == nil then return end
        if pt['log'] then val = math.log(val + 1) end
        draw_ring(cr, val, pt)
    end
end

function conky_rings()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display,
                                         conky_window.drawable,
                                         conky_window.visual,
                                         conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    for i in pairs(elements) do setup_rings(cr, elements[i]) end
end
