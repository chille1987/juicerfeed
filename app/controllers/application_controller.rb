class ApplicationController < ActionController::Base
  include Pagy::Method

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
