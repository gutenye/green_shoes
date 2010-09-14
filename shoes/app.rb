module Shoes
  class << self
    attr_accessor :canvas, :cslot
    attr_reader :contents
  end

  def self.app args={}, &blk
    args[:width] ||= 600
    args[:height] ||= 500
    args[:title] ||= 'green shoes'
    @cslot = self
    @contents = []
    Flow.new basic_attributes

    win = Gtk::Window.new
    win.icon = Gdk::Pixbuf.new 'static/gshoes-icon.png'
    win.title = args[:title]
    win.set_default_size args[:width], args[:height]
    win.signal_connect("destroy"){Gtk.main_quit}

    @canvas = Gtk::Layout.new
    win.add @canvas

    instance_eval &blk
    contents_alignment @contents
    
    win.show_all
    Gtk.main
  end

  def self.stack args={}, &blk
    Stack.new basic_attributes(args), &blk
  end

  def self.flow args={}, &blk
    Flow.new basic_attributes(args), &blk
  end
  
  def self.para *msg
    args = msg.last.class == Hash ? msg.pop : {}
    args = basic_attributes args
    msg = msg.join
    da = Gtk::DrawingArea.new
    da.set_size_request 8*msg.length, 18
    da.signal_connect "expose-event" do |widget, event|
      context = widget.window.create_cairo_context
      layout = context.create_pango_layout
      layout.text = msg
      context.show_pango_layout layout
      context.show_page
    end
    @canvas.put da, args[:left], args[:top]
    da.show_now
    args[:real] = da
    Para.new args
  end

  def self.image name, args={}
    args = basic_attributes args
    img = Gtk::Image.new name
    @canvas.put img, args[:left], args[:top]
    img.show_now
    args[:real] = img
    Image.new args
  end

  def self.button name, args={}, &blk
    args = basic_attributes args
    b = Gtk::Button.new name
    b.signal_connect "clicked", &blk if blk
    @canvas.put b, args[:left], args[:top]
    b.show_now
    args[:real], args[:text] = b, name
    Button.new args
  end

  def self.animate n=10, &blk
    n, i = 1000 / n, 0
    a = Anim.new
    GLib::Timeout.add(n){blk[i = a.pause? ? i : i+1]; a.continue?}
    a
  end
end