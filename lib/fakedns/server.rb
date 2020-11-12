require 'resolv'

module FakeDNS
  MAX_SIZE = 512    # Max allowed bytes in a UDP datagram anyways.
  class Server
    ##
    # Create a fake UDP server. 
    def initialize(ip_addr, port, resolv_ip = nil)
      @ip_addr = ip_addr
      @port = port
      @socket = UDPSocket.new
      @resolv_ip = resolv_ip
      @resolv_ip = @ip_addr if @resolv_ip.nil? or @resolv_ip.empty?
    end
    ##
    # Create fake response
    
    def create_fake_response(msg_klass)
      resp = msg_klass
      resp.qr = 1                                    # Set query (0) / response (1) flag.
      domain_name, resource = resp.question[0]              # Extract domain-name and typeclass.
      
      # Create typeclass with either NIC' IP or given resolv-ip based questions typeclass.
      if resource.eql? Resolv::DNS::Resource::IN::A
        resource = Resolv::DNS::Resource::IN::A.new(@resolv_ip)
        resp.add_answer(domain_name, rand(0xff), resource)
      end
      return resp
    end
    ##
    # Is data a dns-request?.
    
    def is_dns_request?(data)
      # Q/R-bit(bit7) is 0 and, Recursion desired? or not? (bit0).
      return true if data[2].eql? "\x01" or data[2].eql? "\x00"
      return false
    end
    
    ##
    # Display sender, requested domain and if $lookup is set, display resolved ip-address.
    
    def display_query(sender, domain_name, resolved)
      if $lookup
        if resolved.nil? or resolved.empty?
          resolved = " <=> Not found."
        else
          resolved = " <=> #{resolved.first}"
        end 
      end
      puts "Request from #{sender[3]} <=> #{domain_name} #{resolved}"
      end
    
    :public
    ##
    # Stop FakeDNS Server.
    def stop
      if @socket
        @socket.close
        return true
      end
      return false
    end
    ##
    # Start FakeDNS Server.
    
    def start
      @socket.bind @ip_addr, @port
      puts "Starting FakeDNS server at #{@ip_addr}:#{@port}"
      puts "-" * 40
      while @socket
        data, sender = @socket.recvfrom  MAX_SIZE
        if is_dns_request? data
          request = Resolv::DNS::Message.decode data
          domain_name = request.question.first.first.to_s
          
          resolved = Resolv.getaddresses(domain_name) if $lookup
          display_query(sender, domain_name, resolved)
          
          response = create_fake_response request
          @socket.send response.encode, 0, sender[3], sender[1]
        end
      end
    end
  end
end