module ProductOptionsHelper

  def localized_size_unit(size_unit, type: :word, count: 1)
    t_key = "product_options.size_unit.#{size_unit}"
    case type
    when :word
      t t_key, count: count
    when :abbreviation, :abbr
      t t_key + '.abbreviation', count: count
    when :label
      "#{t t_key, count: count} (#{t t_key + '.abbreviation', count: count})"
    end
  end

  def localized_product_size(product_option)
    size = product_option.size.to_s_significant
    size << ' '
    size << localized_size_unit(product_option.size_unit, type: :abbreviation)
  end

  def localized_product_equivalent(product_option)
    t 'product_options.equivalent_in_milk_liters_msg',
      liters: product_option.equivalent_in_milk_liters.to_s_significant
  end
end
