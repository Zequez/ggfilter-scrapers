module Scrapers
  class ScrapRequest
    attr_reader :root_url, :url, :input, :resource, :root, :output, :response, :request

    def initialize(root_url, url = nil, input = nil, resource = nil, root = nil)
      @root_url = root_url
      @url = url || root_url
      @input = input
      @resource = resource
      @root = root

      @response = nil
      @output = nil
      @finished = false
      @error = false
    end

    def set_output(value)
      @output = value
    end

    def set_response(value)
      @request = value.request
      @response = value
    end

    def clear_response
      @request = nil
      @response = nil
    end

    def destroy
      @root = nil
      @requests = []
      @subrequests = []
    end

    def root?
      @is_root ||= @root == self
    end

    def finished!
      @finished = true
    end

    def error!
      @error = true
    end

    def error?
      @error
    end

    def finished?
      @finished
    end

    def subrequest!(url)
      return nil if @root.was_url_requested? url
      @root.add_subrequest ScrapRequest.new(@group_url, url, @input, @resource, @root)
    end
  end
end
