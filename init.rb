require 'live_validations'

# Dynamic adapter loading.
ActiveSupport::Dependencies.load_paths.unshift(File.join(File.dirname(__FILE__), 'lib'))

# Hook into ActiveRecord.
ActiveRecord::Base.class_eval { include LiveValidations::ActiveRecordHooks }

# Hook view helpers
ActionView::Base.class_eval { include LiveValidations::ViewHelpers }

## Hook into the default form builder
ActionView::Helpers::FormBuilder.class_eval { include LiveValidations::FormBuilder }