module BlueHydra
  module Pulse
    def reset
      if BlueHydra.pulse ||  BlueHydra.pulse_debug

        BlueHydra.logger.info("Sending db reset to pulse")

        json_msg = JSON.generate({
          type:    "reset",
          source:  "blue-hydra",
          version: BlueHydra::VERSION,
          sync_version: BlueHydra::SYNC_VERSION,
        })

        BlueHydra::Pulse.do_send(json_msg)
      end
    end

    def do_send(json)
      BlueHydra::Pulse.do_debug(json) if BlueHydra.pulse_debug
      return unless BlueHydra.pulse
      begin
        # write json data to result socket
        TCPSocket.open('127.0.0.1', 8244) do |sock|
          sock.write(json)
          sock.write("\n")
          sock.flush
        end
      rescue => e
        BlueHydra.logger.warn "Unable to connect to Hermes (#{e.message}), unable to send to pulse"
      end
    end

    def do_debug(json)
      File.open("pulse_debug.log", 'a') { |file| file.puts(json) }
    end

    module_function :do_send, :reset, :do_debug
  end
end
