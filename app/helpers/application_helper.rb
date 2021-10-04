module ApplicationHelper
  def sortable(column:, coltitle: nil, view: nil, direction: 'asc')
    # "AvScore".titleize = "Av Score"
    coltitle ||= column.titleize
    # sort_colum is a private method of the controller
    # sort_direction is a method of the application controller
    css_class = column == sort_column(view) ? "current #{sort_direction(direction: direction)}" : 'notcurrent'
    if column == sort_column(view) && sort_direction(direction: direction) == direction
      direction = opp_direction(direction)
    end
    link_to coltitle, { sort: column, direction: direction }, { class: css_class, remote: false }
  end

  def opp_direction(direction)
    return 'desc' if direction == 'asc'

    'asc'
  end
end
