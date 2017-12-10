/*
* Copyright (c) 2017
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Felipe Escoto <felescoto95@hotmail.com>
*/

/**
 * This is a {@link GtkClutter.Embed} object that holds and renders {@link GtkCanvas.CanvasItem} and their subclasses
 *
 * This class should take care of zoom-in/out, and maintaing the aspect ratio of this and it's CanvasItems when the canvas is resized.
 */
public class GtkCanvas.Canvas : GtkClutter.Embed {
    private List<CanvasItem> items;

    private int current_allocated_width;
    private double current_ratio;

    /**
    * This value controls the zoom level the items will use.
    * A larger value means that the item will be smaller (As if looked from further away)
    *
    * Defaults to 500.0.
    */
    public double zoom_level {
        get {
            return _zoom_level;
        } set {
            _zoom_level = value;
            update_current_ratio ();
        }
    }
    private double _zoom_level = 500.0;

    construct {
        var actor = get_stage ();
        actor.background_color = Clutter.Color.from_string ("white");
        set_use_layout_size (false);

        items = new List<CanvasItem>();
    }

   /**
    * Adds a test shape. Great for testing the library!
    *
    * @param color the color the test-shape will be, in CSS format
    * @param rotation the amount of degrees the item will be rotated
    */
    public void add_test_shape (string color, double rotation) {
        var item = new CanvasItem ();
        item.background_color = Clutter.Color.from_string (color);

        var rotate = new Clutter.RotateAction ();
        rotate.rotate (item, rotation);

        add_item (item);
    }

    /**
    * Adds a {@link CanvasItem} to this
    *
    * @param item the canvas item to be added
    */
    public void add_item (CanvasItem item) {
        items.prepend (item);
        get_stage ().add_child (item);
    }

    // TODO: Keep canvas on the same aspect ratio (like 16:9). Maybe use a Gtk.AspectFrame?
    private void update_current_ratio () {
        current_allocated_width = get_allocated_width ();
        if (current_allocated_width < 0) return;

        current_ratio = (double)(current_allocated_width - 24) / zoom_level;

        foreach (var item in items) {
            item.apply_ratio (current_ratio);
        }
    }

    public override bool draw (Cairo.Context cr) {
        if (current_allocated_width != get_allocated_width ()) {
            update_current_ratio ();
        }

        return base.draw (cr);
    }
}