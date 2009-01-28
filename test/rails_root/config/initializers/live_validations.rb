# Makes rails aware of the plugin.
lib_path = File.join(Rails.root, '..', '..')
$LOAD_PATH << lib_path
load File.join(lib_path, 'init.rb')

# Pretend like nothing happened.
LiveValidations.use LiveValidations::Adapters::JqueryValidations
