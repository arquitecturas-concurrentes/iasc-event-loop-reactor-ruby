require 'rspec'
require_relative '../src/reactor_exceptions'
require_relative '../src/signal_handler'

describe 'Signal Handler testing' do


  it 'fails when setting an invalid signal' do
    expect { Reactor::SignalHandler.define_trap :SOMETHING do
      exit
    end }.to raise_error Reactor::SignalHandlerException

  end

  it 'catches a TERM signal' do
    # The MRI default TERM handler does not cause RSpec to exit with an error.
    # Use the system default TERM handler instead, which does kill RSpec.
    # If you test a different signal you might not need to do this,
    # or you might need to install a different signal's handler.
    pid = fork do
      Reactor::SignalHandler.define_trap(:TERM) do
        exit
      end
      expect(Reactor::SignalHandler).to receive(:define_trap).with array_including(:TERM)
      Signal.should_receive(:trap).at_most(1).times
    end

    Process.detach(pid)
    Process.kill :TERM, pid # Send the signal to ourself
  end

  it 'test term_trap exit signal' do
    pid = fork do
      Reactor::SignalHandler.define_term_trap do
        b = 3
      end
      expect(Reactor::SignalHandler).to receive(:define_term_trap)
      Signal.should_receive(:trap).at_most(1).times
    end

    Process.detach(pid)
    Process.kill :TERM, pid # Send the signal to ourself
  end

  it 'catches an INT signal' do

    pid = fork do
      Reactor::SignalHandler.define_int_trap do
        a = 1
      end
      expect(Reactor::SignalHandler).to receive(:define_int_trap)
      Signal.should_receive(:trap).at_most(1).times
    end

    Process.kill :INT, pid # Send the signal to ourself
  end

  it 'same if we call define_trap method' do
    signals = [:QUIT, :INT, :TERM]

    signals.each do |sig|

      pid = fork do
        Reactor::SignalHandler.define_trap sig do
          a = 1
        end
        expect(Reactor::SignalHandler).to receive(:define_trap).at_most(1).times
        Signal.should_receive(:trap).at_most(1).times
      end

      Process.kill sig, pid # Send the signal to ourself

    end
  end
end