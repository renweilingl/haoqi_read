# frozen_string_literal: true

# Allow BigDecimal in YAML deserialization for the audited gem.
# Without this, Psych::DisallowedClass is raised when audited
# serializes numeric attribute changes.
ActiveSupport.on_load(:active_record) do
  ActiveRecord.yaml_column_permitted_classes << BigDecimal unless
    ActiveRecord.yaml_column_permitted_classes.include?(BigDecimal)
end
