#####################################################################
###	P U B L I C A T I O N   T A S K S
#####################################################################

RELEASE_NOTES_FILE    = 'release.notes'
RELEASE_ANNOUNCE_FILE = 'release.ann'

require 'net/smtp'
require 'net/protocol'
require 'openssl'

$publish_privately = false

### Add SSL to Net::SMTP
class Net::SMTP
	def ssl_start( helo='localhost.localdomain', user=nil, secret=nil, authtype=nil )
		if block_given?
			begin
				do_ssl_start( helo, user, secret, authtype )
				return yield( self )
			ensure
				do_finish
			end
		else
			do_ssl_start( helo, user, secret, authtype )
			return self
		end
	end


	#######
	private
	#######

	def do_ssl_start( helodomain, user, secret, authtype )
		raise IOError, 'SMTP session already started' if @started
		if user or secret
			if self.method( :check_auth_args ).arity == 3
				check_auth_args( user, secret, authtype )
			else
				check_auth_args( user, secret )
			end
		end

		# Open the connection
      	@debug_output << "opening connection to #{@address}...\n" if @debug_output
		sock = timeout( @open_timeout ) { TCPsocket.new(@address, @port) }

		# Wrap it in the SSL layer
		ssl_context = OpenSSL::SSL::SSLContext.new
		ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
		ssl_sock = OpenSSL::SSL::SSLSocket.new( sock, ssl_context )
		ssl_sock.sync_close = true
		ssl_sock.connect

		# Wrap it in the message-oriented IO layer
		sslmsgio = Net::InternetMessageIO.new( ssl_sock )
		sslmsgio.read_timeout = @read_timeout
		sslmsgio.debug_output = @debug_output

		@socket = sslmsgio

		check_response(critical { recv_response() })
		begin
			if @esmtp
				ehlo helodomain
			else
				helo helodomain
			end
		rescue ProtocolError
			if @esmtp
				@esmtp = false
				@error_occured = false
				retry
			end
			raise
		end
		authenticate user, secret, authtype if user
		@started = true
	ensure
		@socket.close if not @started and @socket and not @socket.closed?
	end
end


begin
	gem 'text-format'

	require 'time'
	require 'rake/tasklib'
	require 'tmail'
	require 'net/smtp'
	require 'etc'
	require 'socket'
	require 'text/format'

	### Generate a valid RFC822 message-id
	def gen_message_id
		return "<%s.%s@%s>" % [
			(Time.now.to_f * 10000).to_i.to_s( 36 ),
			(rand( 2 ** 64 - 1 )).to_s( 36 ),
			Socket.gethostname
		]
	end


	namespace :release do
		task :default => [ :prep_release, :upload, :publish, :announce ]

		desc "Re-publish the release with the current version number"
		task :rerelease => [  :upload, :publish, :announce ]

		desc "Re-run the publication tasks, but send notifications to debugging address"
		task :test do
			trace "Will publish privately"
			$publish_privately = true
			Rake::Task['release:rerelease'].invoke
		end


		desc "Generate the release notes"
		task :notes => [RELEASE_NOTES_FILE]
		file RELEASE_NOTES_FILE do |task|
			last_tag = MercurialHelpers.get_tags.grep( /\d+\.\d+\.\d+/ ).
				collect {|ver| vvec(ver) }.sort.last.unpack( 'N*' ).join('.')

			File.open( task.name, File::WRONLY|File::TRUNC|File::CREAT ) do |fh|
				fh.puts "Release Notes for #{PKG_VERSION}",
				        "--------------------------------", '', ''
			end

			edit task.name
		end
		CLOBBER.include( RELEASE_NOTES_FILE )


		desc "Upload project documentation and packages to #{PROJECT_HOST}"
		task :upload => [ :upload_docs, :upload_packages ]
		task :project => :upload # the old name

		desc "Publish the project docs to #{PROJECT_HOST}"
		task :upload_docs => [ :rdoc ] do
			when_writing( "Publishing docs to #{PROJECT_SCPDOCURL}" ) do
				log "Uploading API documentation to %s:%s" % [ PROJECT_HOST, PROJECT_DOCDIR ]
				run 'ssh', PROJECT_HOST, "rm -rf #{PROJECT_DOCDIR}"
				run 'scp', '-qCr', RDOCDIR, PROJECT_SCPDOCURL
			end
		end

		desc "Publish the project packages to #{PROJECT_HOST}"
		task :upload_packages => [ :package ] do
			when_writing( "Uploading packages") do
				pkgs = Pathname.glob( PKGDIR + "#{PKG_FILE_NAME}.{gem,tar.gz,tar.bz2,zip}" )
				log "Uploading %d packages to #{PROJECT_SCPPUBURL}" % [ pkgs.length ]
				pkgs.each do |pkgfile|
					run 'scp', '-qC', pkgfile, PROJECT_SCPPUBURL
                end
            end
		end


		file RELEASE_ANNOUNCE_FILE => [RELEASE_NOTES_FILE] do |task|
			relnotes = File.read( RELEASE_NOTES_FILE )
			announce_body = %{

				Version #{PKG_VERSION} of #{PKG_NAME} has been released.

				#{Text::Format.new(:first_indent => 0).format_one_paragraph(GEMSPEC.description)}

				== Project Page

				  #{GEMSPEC.homepage}

				== Installation

				Via gems:

				  $ sudo gem install #{GEMSPEC.name}

				or from source:

				  $ wget http://deveiate.org/code/#{PKG_FILE_NAME}.tar.gz
				  $ tar -xzvf #{PKG_FILE_NAME}.tar.gz
				  $ cd #{PKG_FILE_NAME}
				  $ sudo rake install

				== Changes
				#{relnotes}
			}.gsub( /^\t+/, '' )

			File.open( task.name, File::WRONLY|File::TRUNC|File::CREAT ) do |fh|
				fh.print( announce_body )
			end

			edit task.name
		end
		CLOBBER.include( RELEASE_ANNOUNCE_FILE )


		desc 'Send out a release announcement'
		task :announce => [RELEASE_ANNOUNCE_FILE] do
			email         = TMail::Mail.new

			if $publish_privately || RELEASE_ANNOUNCE_ADDRESSES.empty?
				trace "Sending private announce mail"
				email.to = 'rubymage@gmail.com'
			else
				trace "Sending public announce mail"
				email.to  = RELEASE_ANNOUNCE_ADDRESSES
				email.bcc = 'rubymage@gmail.com'
			end
			email.from    = 'Michael Granger <mgranger@laika.com>'
			email.subject = "[ANN] #{PKG_NAME} #{PKG_VERSION}"
			email.body    = File.read( RELEASE_ANNOUNCE_FILE )
			email.date    = Time.new

			email.message_id = gen_message_id()

			log "About to send the following email:"
			puts '---',
			     email.to_s,
			     '---'

				ask_for_confirmation( "Will send via #{SMTP_HOST}." ) do
				pwent = Etc.getpwuid( Process.euid )
				curuser = pwent ? pwent.name : 'unknown'
				username = prompt_with_default( "SMTP user", curuser )
				password = prompt_for_password()

				trace "Creating SMTP connection to #{SMTP_HOST}:#{SMTP_PORT}"
				smtp = Net::SMTP.new( SMTP_HOST, SMTP_PORT )
				smtp.set_debug_output( $stdout )
				smtp.esmtp = true

				trace "connecting..."
				smtp.ssl_start( Socket.gethostname, username, password, :plain ) do |smtp|
					trace "sending message..."
					smtp.send_message( email.to_s, email.from, email.to )
				end
				trace "done."
			end
		end


		desc 'Publish the new release to Gemcutter'
		task :publish => [:clean, :gem, :notes] do |task|
			ask_for_confirmation( "Publish #{GEM_FILE_NAME} to Gemcutter?", false ) do
				gempath = PKGDIR + GEM_FILE_NAME
				sh 'gem', 'push', gempath
			end
		end
	end

rescue LoadError => err
	if !Object.const_defined?( :Gem )
		require 'rubygems'
		retry
	end

	task :no_release_tasks do
		fail "Release tasks not defined: #{err.message}"
	end

	task :release => :no_release_tasks
	task "release:announce" => :no_release_tasks
	task "release:publish" => :no_release_tasks
	task "release:notes" => :no_release_tasks
end

desc "Package up a release, publish it, and send out notifications"
task :release => 'release:default'
task :rerelease => 'release:rerelease'
task :testrelease => 'release:test'

