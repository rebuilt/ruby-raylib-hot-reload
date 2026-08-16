class State < Hash
  def initialize(*args)
    super
    # Wrap all nested hashes on initialization
    transform_values { |v| v.is_a?(Hash) ? self.class.new(v) : v }
  end

  def method_missing(name, *args)
    # Strip the trailing '=' for setters
    if name.to_s.end_with?('=') && args.length == 1
      self[name.to_s.chop.to_sym] = args.first
      return
    end

    key = name.to_sym
    if key.nil? || !has_key?(key)
      if args.length == 1 && args.first.is_a?(Hash)
        # args.game = { player: { x: 10 } }
        self[key] = self.class.new(args.first)
        return
      end
      raise NoMethodError, "undefined method '#{name}' for #{self.inspect}"
    end

    value = self[key]
    value.is_a?(Hash) ? value : value
  end

  def respond_to_missing?(name, include_private = false)
    true  # always respond — we handle everything via method_missing
  end
end

