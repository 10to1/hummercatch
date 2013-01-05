# -*- coding: utf-8 -*-
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'minitest' do
  # with Minitest::Spec
  watch(%r|^spec/(.*)_spec\.rb|)
  watch(%r|^spec/helper\.rb|)    { "test" }
  watch(%r|^app/models/(.*)\.rb|) { |m| "spec/#{m[1]}_spec.rb" }
end
