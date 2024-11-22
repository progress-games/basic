Button = Description:extend()

function Button:new(args)
    self.scale = Spring(args.scale or 1)

    self.func = args.func or nothing
    self.right_func = args.right_func or nothing
    self.static = args.static or false
    self.alt_text = args.alt_text or {args.text}

    Button.super.new(self, args)
end

function Button:update(dt)
    
end