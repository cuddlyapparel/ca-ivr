require 'twilio-ruby'

class TwilioController < ApplicationController
	include Webhookable

	after_filter :set_header

	skip_before_action :verify_authenticity_token

	def index
		response = Twilio::TwiML::Response.new do |r|
			r.Gather :numDigits => '1', :action => '/gather', :method => 'get' do |g|
				# +18888814289	THA Main
				if params['Called'] == '+18888814289'
					g.Play 'http://blackfin-co.s3.amazonaws.com/2015/09/150923_tha_symantec_vm_1.mp3'
				else
				# +18888580009	BSG Main
					g.Play 'http://blackfin-co.s3.amazonaws.com/2015/09/150923_bsg_symantec_vm_0.mp3'
				end
			end
		end

		render_twiml response
	end

	def gather
		redirect_to '/' unless ['1', '2', '3', '4'].include?(params['Digits'])

		response = Twilio::TwiML::Response.new do |r|
			r.Play 'http://blackfin-co.s3.amazonaws.com/2014/09/083014bsg-vm2.mp3'
			r.Record :maxLength => '120', :action => '/recording?d=' + params['Digits'] + '&from=' + params['From'], :method => 'get'
		end

		render_twiml response
	end

	def recording
		response = Twilio::TwiML::Response.new do |r|

			message = Hash.new

			case params['d'].to_i
			when 1
				destination = 'matt@cuddlyapparel.com'
			when 2
				destination = 'matt@cuddlyapparel.com'
			when 3
				destination = 'matt@cuddlyapparel.com'
			else
				destination = 'matt@cuddlyapparel.com'
			end

			message = { 'caller' => params['From'], 'destination' => destination, 'message_url' => params['RecordingUrl'] }

			ModelMailer.new_vm_notification(message).deliver
		end

		render_twiml response
	end

end
