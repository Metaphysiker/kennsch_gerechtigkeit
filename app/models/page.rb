class Page < ApplicationRecord
  after_save :render_content
  after_save :set_order

  def render_content
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
    rendered = markdown.render(self.content)
    self.update_columns(content_rendered: rendered)
  end


  has_one_attached :cover
  extend FriendlyId
  friendly_id :title, use: :slugged

  def set_order
    array_number_of_pages = (1..Page.all.count).to_a
    actual_order = Page.all.order(:order).pluck(:order)
    missing_number = array_number_of_pages - actual_order

    if self.order.blank?
      self_order = Page.all.count + 1
    else
      self_order = self.order
    end

    Page.where(order: self_order).each do |page|
      next if page == self
      page.update_columns(order: missing_number.first)
    end

    Page.all.each do |page|
      next if page == self
      if page.order == self_order || page.order > self_order
        #puts page.title
        page.update_columns(order: page.order + 1)
      end
      #page.update(order: start_value)
    end

    #to ensure that it is always 1..10 and not 2..4..7
    start_value = 0
    Page.all.order(:order).each do |page|
      start_value += 1
      page.update_columns(order: start_value)
    end

  end

end
