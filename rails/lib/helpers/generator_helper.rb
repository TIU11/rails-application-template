# frozen_string_literal: true

# TODO: where should we put shared generator code?
module Helpers
  module GeneratorHelper
    class << self
    end

    # Read a template file from the generator's templates folder
    def read_template(path)
      path = File.join(self.class.source_root, path)
      File.open(path).read
    end
  end
end
