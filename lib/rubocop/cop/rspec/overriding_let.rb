# frozen_string_literal: true

module RuboCop
  module Cop
    module RSpec
      # This Cop checks for the usage of `let` in RSpec tests to ensure that
      # `let` variables are not overridden within the nested example groups.
      # Overriding `let` variables can lead to confusing and
      # hard-to-maintain tests.
      #
      # This cop will add an offense if a `let` variable is overridden within
      # the same example group or nested contexts.
      #
      # @example
      #   # bad
      #   RSpec.describe do
      #     let(:params) do
      #       {
      #         limit:,
      #         offset:,
      #         sort:,
      #         order:
      #       }
      #     end
      #     let(:limit) { 10 }
      #     let(:offset) { 0 }
      #     let(:sort) { 'id' }
      #     let(:order) { 'asc' }
      #
      #     describe 'limit' do
      #       context 'when limit is 20' do
      #         let(:limit) { 20 }
      #         it { expect(result.length).to eq(20) }
      #       end
      #
      #       context 'when limit is 30' do
      #         let(:limit) { 30 }
      #         it { expect(result.length).to eq(30) }
      #       end
      #     end
      #
      #     describe 'offset' do
      #       context 'when offset is 10' do
      #         let(:offset) { 10 }
      #         it { expect(result.first.id).to eq(11) }
      #       end
      #
      #       context 'when offset is 20' do
      #         let(:offset) { 20 }
      #         it { expect(result.first.id).to eq(21) }
      #       end
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe do
      #     describe 'limit' do
      #       let(:params) do
      #         {
      #           limit:,
      #           offset: 0,
      #           sort: 'id',
      #           order: 'asc'
      #         }
      #       end
      #
      #       context 'when limit is 20' do
      #         let(:limit) { 20 }
      #         it { expect(result.length).to eq(20) }
      #       end
      #
      #       context 'when limit is 30' do
      #         let(:limit) { 30 }
      #         it { expect(result.length).to eq(30) }
      #       end
      #     end
      #
      #     describe 'offset' do
      #       let(:params) do
      #         {
      #           limit: 10,
      #           offset:,
      #           sort: 'id',
      #           order: 'asc'
      #         }
      #       end
      #
      #       context 'when offset is 10' do
      #         let(:offset) { 10 }
      #         it { expect(result.first.id).to eq(11) }
      #       end
      #
      #       context 'when offset is 20' do
      #         let(:offset) { 20 }
      #         it { expect(result.first.id).to eq(21) }
      #       end
      #     end
      #   end
      #
      class OverridingLet < Base
        MSG = 'Do not override let.'

        def on_block(node)
          example_group = RuboCop::RSpec::ExampleGroup.new(node)
          return if example_group.lets.empty?

          example_group.lets.each do |let_node|
            let_name = extract_let_name(let_node)
            next unless overrided?(node.parent, let_name)

            add_offense(let_node)
          end
        end

        alias on_numblock on_block

        def overrided?(node, let_name)
          return false if node.nil?

          example_group = RuboCop::RSpec::ExampleGroup.new(node)
          example_group.lets.any? do |let_node|
            upper_let_name = extract_let_name(let_node)

            next unless upper_let_name

            upper_let_name == let_name
          end || overrided?(node.parent, let_name)
        end

        def extract_let_name(node) # rubocop:disable Metrics/MethodLength
          case node.type
          when :send
            return false unless node.method?(:let) || node.method?(:let!)

            extract_let_name(node.first_argument)
          when :block
            extract_let_name(node.send_node)
          when :begin
            extract_let_name(node.children.first)
          when :lvar
            # When the node is a local variable (`lvar`), it returns false
            # because the content of the variable is unknown when linting.
            false
          when :sym
            node.value
          when :str
            node.value.to_sym
          else
            raise "Unexpected node type: #{node.type}"
          end
        end
      end
    end
  end
end
