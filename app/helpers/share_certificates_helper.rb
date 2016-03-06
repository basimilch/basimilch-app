module ShareCertificatesHelper

def date_field(form, field_name)
  content_tag(:div, class: "field date-field") do
    concat form.label(field_name)
    if date = form.object.try(field_name)
      # Do not allow to edit the dates that are already set up.
      concat content_tag(:div, date.to_date.to_localized_s(:long))
    else
      concat form.date_select(field_name,
                              include_blank: true,
                              default: nil,
                              start_year: 2015)
    end
  end
end

end
