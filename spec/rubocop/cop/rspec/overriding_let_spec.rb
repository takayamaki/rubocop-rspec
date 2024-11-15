# frozen_string_literal: true

RSpec.describe RuboCop::Cop::RSpec::OverridingLet do
  let(:cop_config) do
    {}
  end

  it 'registers an offense when let is overridden in context' do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo) { 1 }

        context do
          let(:foo) { 2 }
          ^^^^^^^^^^^^^^^ Do not override let.
        end
      end
    RUBY
  end

  it 'does not register an offense when different let is used in context' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe do
        let(:foo) { 1 }

        context do
          let(:bar) { 2 }
        end
      end
    RUBY
  end

  it 'registers an offense when let is overridden in describe' do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo) { 1 }

        describe do
          let(:foo) { 2 }
          ^^^^^^^^^^^^^^^ Do not override let.
        end
      end
    RUBY
  end

  it 'does not register an offense when different let is used in describe' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe do
        let(:foo) { 1 }

        describe do
          let(:bar) { 2 }
        end
      end
    RUBY
  end

  it 'registers an offense when let! is overridden in context' do
    expect_offense(<<~RUBY)
      RSpec.describe do
        let(:foo) { 1 }

        context do
          let!(:foo) { 2 }
          ^^^^^^^^^^^^^^^^ Do not override let.
        end
      end
    RUBY
  end

  it 'does not register an offense when different let! is used in context' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe do
        let(:foo) { 1 }

        context do
          let!(:bar) { 2 }
        end
      end
    RUBY
  end

  it 'does not register an offense when let name is via method invoke' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe do
        let(let_name_via_method_invoke) { 1 }

        context do
          let!(let_name_via_method_invoke) { 2 }
        end
      end
    RUBY
  end

  it 'does not register an offense when let name is via local variable' do
    expect_no_offenses(<<~RUBY)
      RSpec.describe do
        let_name_via_local_variable = :foo
        let(let_name_via_local_variable) { 1 }

        context do
          let!(let_name_via_local_variable) { 2 }
        end
      end
    RUBY
  end
end
