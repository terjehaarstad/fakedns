require 'test/unit'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '/../lib'))
require 'fakedns'

def resolv_name
	addr = Resolv::DNS.new(:nameserver_port => [["127.0.0.1", 1053]]).getaddress("www.google.com").address.each_byte.to_a.join(".")
end


class TestServer < Test::Unit::TestCase
	class << self
		def startup 
			@@resolv = "127.0.0.2"
			
			@@server = FakeDNS::Server.new("127.0.0.1", 1053, "127.0.0.2")
			@@thread = Thread.new {@@server.start}
			@@query = Resolv::DNS::Message.new
			@@query.id = 0x0101
			@@query.add_question(Resolv::DNS::Name.create("www.google.com"), Resolv::DNS::Resource::IN::A)
		end
	end
	def test_fake_response
		response = @@server.create_fake_response(@@query)
		assert_equal response.id, @@query.id
		assert_equal response.qr, 1
		assert_equal response.question.size, 1
		assert_equal response.answer.size, 1
		assert_equal response.answer[0].size, 3
		assert_equal response.answer[0][0].to_s, "www.google.com"
		assert_equal response.answer[0][2].address.to_s, "127.0.0.2"
	end
	def test_resolv
		addr = resolv_name
		assert_equal @@resolv, addr
	end
	def kill_server
		@@server.close
		@@thread.kill
	end
end
