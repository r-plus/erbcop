# frozen_string_literal: true

require 'parser'
require 'rubocop/cop/legacy/corrector'

module Erbcop
  # Apply auto-corrections to Erb file.
  class ErbCorrector
    # @param [String] file_path
    # @param [Array<Erbcop::Offense>] offenses
    # @param [String] source
    def initialize(file_path:, offenses:, source:)
      @file_path = file_path
      @offenses = offenses
      @source = source
    end

    # @return [String] Rewritten Erb code.
    def call
      ::RuboCop::Cop::Legacy::Corrector.new(source_buffer, corrections).rewrite
    end

    private

    # @return [Array<Proc>]
    def corrections
      @offenses.select(&:corrector).map do |offense|
        lambda do |corrector|
          corrector.import!(offense.corrector, offset: offense.offset)
        end
      end
    end

    # @return [Parser::Source::Buffer]
    def source_buffer
      ::Parser::Source::Buffer.new(
        @file_path,
        source: @source
      )
    end
  end
end
