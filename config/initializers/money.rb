Money.default_currency = Money::Currency.new("USD")
Money.locale_backend = :i18n
Money.rounding_mode = BigDecimal::ROUND_HALF_UP
I18n.enforce_available_locales = false
