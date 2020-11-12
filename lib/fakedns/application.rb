require 'optparse'

#
# Application Library for FakeDNS
#
module FakeDNS
  class Application
    def initialize(args)
      @args = args
    end

    def run
      begin
        parse_options(@args)
        #
        # Enable sniffer

        @port = @options[:port]
        @port = 53 if @port.nil? or @port.empty?
        
        $lookup = true	if @options[:lookup]
        #
        # Set up Server-object.

        if @options[:resolv_ip] and @options[:interface]
          @server = Server.new(@ip_addr, @port, @options[:resolv_ip])

        elsif @options[:interface]
          @server = Server.new(@ip_addr, @port)
        #
        # Show help
        else
          @args << "--help"
          parse_options(@args)
        end

        # Start Server.
        @server.start

      rescue Interrupt
        puts "Goodbye.."
      rescue Errno::EACCES => error
        puts error.to_s + ", try another port or as super-user.."
      ensure
      @server.stop if @server
      end

    end
    def putserr(str)
		puts "[!!] #{str}"
	end
    def parse_options(arguments)
      begin
      #
      # Show help if no arguments are given
        @options = {}
        opts = OptionParser.new do |opts|
          opts.banner=("-====================================-\n")
          opts.separator("    #{APP_NAME} v#{VERSION} by #{AUTHOR}")
          opts.separator("-====================================-\n\n")
          opts.separator("Usage: #{$0} -i <INTERFACE> <options>")
          opts.separator("Options:")
          #
          # Help options
          opts.on('-h', '--help', 'This Screen') do
            puts opts
            exit
          end
          #
          # Interface to listen on
          opts.on('-i', '--interface INTERFACE', 'Interface to start FakeDNS server on') do |iface|
            @options[:interface] = iface
            Socket.getifaddrs.each do |int|
              @ip_addr = int.addr.ip_address if int.addr.ipv4? and int.name.eql? iface
            end
          end
          #
          # Show resolved ip-addresses
          opts.on('-l', '--lookup', 'Enables resolver and display addresses.') do |lookup|
            @options[:lookup] = lookup
          end
          opts.on('-p', '--port [PORT]', 'Port to listen on. (Default: 53)') do |port|
            @options[:port] = port
          end
          #
          # Redirect Option
          opts.on('-r', '--resolve [IP]', 'Answer DNSQuery with spesific IP.') do |ip|
            @options[:resolv_ip] = ip
          end
        end
        #
        # Display help if no arguments are given
        opts.parse!(arguments)
      # Rescue me
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
        putserr e
      rescue ArgumentError => e
		putserr e
		exit
      end
    end
  end
end
