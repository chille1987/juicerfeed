module ApplicationHelper
  def svg(filename, options = {})
    asset_path = Rails.root.join("app/assets/images", filename)

    if File.exist?(asset_path)
      file = File.read(asset_path).force_encoding("UTF-8")
      doc = Nokogiri::HTML::DocumentFragment.parse(file)
      svg = doc.at_css "svg"

      svg["class"] = options[:class] if options[:class].present?
      svg["width"] = options[:width] if options[:width].present?
      svg["height"] = options[:height] if options[:height].present?

      raw doc.to_html
    else
      raw "<!-- SVG #{filename} not found -->"
    end
  end
end
