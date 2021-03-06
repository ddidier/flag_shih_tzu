require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class Spaceship < ActiveRecord::Base
  self.table_name = 'spaceships'
  include FlagShihTzu

  has_flags 1 => :warpdrive,
            2 => :shields,
            3 => :electrolytes
end

class SpaceshipWithoutNamedScopes < ActiveRecord::Base
  self.table_name = 'spaceships'
  include FlagShihTzu

  has_flags(1 => :warpdrive, :named_scopes => false)
end

class SpaceshipWithoutNamedScopesOldStyle < ActiveRecord::Base
  self.table_name = 'spaceships'
  include FlagShihTzu

  has_flags({1 => :warpdrive}, :named_scopes => false)
end

class SpaceshipWithCustomFlagsColumn < ActiveRecord::Base
  self.table_name = 'spaceships_with_custom_flags_column'
  include FlagShihTzu

  has_flags(1 => :warpdrive, 2 => :hyperspace, :column => 'bits')
end

class SpaceshipWithColumnNameAsSymol < ActiveRecord::Base
  self.table_name = 'spaceships_with_custom_flags_column'
  include FlagShihTzu

  has_flags(1 => :warpdrive, 2 => :hyperspace, :column => :bits)
end

class SpaceshipWith2CustomFlagsColumn < ActiveRecord::Base
  self.table_name = 'spaceships_with_2_custom_flags_column'
  include FlagShihTzu

  has_flags({ 1 => :warpdrive, 2 => :hyperspace }, :column => 'bits')
  has_flags({ 1 => :jeanlucpicard, 2 => :dajanatroj }, :column => 'commanders')
end

class SpaceshipWith3CustomFlagsColumn < ActiveRecord::Base
  self.table_name = 'spaceships_with_3_custom_flags_column'
  include FlagShihTzu

  has_flags({ 1 => :warpdrive, 2 => :hyperspace }, :column => 'engines')
  has_flags({ 1 => :photon, 2 => :laser, 3 => :ion_cannon, 4 => :particle_beam }, :column => 'weapons')
  has_flags({ 1 => :power, 2 => :anti_ax_routine }, :column => 'hal3000')
end

class SpaceshipWithBitOperatorQueryMode < ActiveRecord::Base
  self.table_name = 'spaceships'
  include FlagShihTzu

  has_flags(1 => :warpdrive, 2 => :shields, :flag_query_mode => :bit_operator)
end

class SpaceshipWithBangMethods < ActiveRecord::Base
  self.table_name = 'spaceships'
  include FlagShihTzu

  has_flags(1 => :warpdrive, 2 => :shields, :bang_methods => true)
end

class SpaceCarrier < Spaceship
end

class SpaceshipWithValidationsAndCustomFlagsColumn < ActiveRecord::Base
  self.table_name = 'spaceships_with_custom_flags_column'
  include FlagShihTzu

  has_flags(1 => :warpdrive, 2 => :hyperspace, :column => 'bits')
  validates_presence_of_flags :bits
end

class SpaceshipWithValidationsAnd3CustomFlagsColumn < ActiveRecord::Base
  self.table_name = 'spaceships_with_3_custom_flags_column'
  include FlagShihTzu

  has_flags({ 1 => :warpdrive, 2 => :hyperspace }, :column => 'engines')
  has_flags({ 1 => :photon, 2 => :laser, 3 => :ion_cannon, 4 => :particle_beam }, :column => 'weapons')
  has_flags({ 1 => :power, 2 => :anti_ax_routine }, :column => 'hal3000')

  validates_presence_of_flags :engines, :weapons
end

class SpaceshipWithValidationsOnNonFlagsColumn < ActiveRecord::Base
  self.table_name = 'spaceships_with_custom_flags_column'
  include FlagShihTzu

  has_flags(1 => :warpdrive, 2 => :hyperspace, :column => 'bits')
  validates_presence_of_flags :id
end

# table planets is missing intentionally to see if flagshihtzu handles missing tables gracefully
class Planet < ActiveRecord::Base
end

class FlagShihTzuClassMethodsTest < Test::Unit::TestCase

  def setup
    Spaceship.destroy_all
  end

  def test_has_flags_should_raise_an_exception_when_flag_key_is_negative
    assert_raises ArgumentError do
      eval(<<-EOF
        class SpaceshipWithInvalidFlagKey < ActiveRecord::Base
          self.table_name = 'spaceships'
          include FlagShihTzu

          has_flags({ -1 => :error })
        end
           EOF
          )
    end
  end

  def test_has_flags_should_raise_an_exception_when_flag_name_already_used
    assert_raises ArgumentError do
      eval(<<-EOF
        class SpaceshipWithAlreadyUsedFlag < ActiveRecord::Base
          self.table_name = 'spaceships_with_2_custom_flags_column'
          include FlagShihTzu

          has_flags({ 1 => :jeanluckpicard }, :column => 'bits')
          has_flags({ 1 => :jeanluckpicard }, :column => 'commanders')
        end
           EOF
          )
    end
  end

  def test_has_flags_should_raise_an_exception_when_desired_flag_name_method_already_defined
    assert_raises ArgumentError do
      eval(<<-EOF
        class SpaceshipWithAlreadyUsedMethod < ActiveRecord::Base
          self.table_name = 'spaceships_with_2_custom_flags_column'
          include FlagShihTzu

          def jeanluckpicard; end

          has_flags({ 1 => :jeanluckpicard }, :column => 'bits')
        end
           EOF
          )
    end
  end

  def test_has_flags_should_raise_an_exception_when_flag_name_method_defined_by_flagshitzu_if_strict
    assert_raises FlagShihTzu::DuplicateFlagColumnException do
      eval(<<-EOF
        class SpaceshipWithAlreadyUsedMethodByFlagshitzuStrict < ActiveRecord::Base
          self.table_name = 'spaceships_with_2_custom_flags_column'
          include FlagShihTzu

          has_flags({ 1 => :jeanluckpicard }, :column => 'bits', :strict => true)
          has_flags({ 1 => :jeanluckpicard }, :column => 'bits', :strict => true)
        end
           EOF
          )
    end
  end

  def test_has_flags_should_not_raise_an_exception_when_flag_name_method_defined_by_flagshitzu
    assert_nothing_raised ArgumentError do
      eval(<<-EOF
        class SpaceshipWithAlreadyUsedMethodByFlagshitzu < ActiveRecord::Base
          self.table_name = 'spaceships_with_2_custom_flags_column'
          include FlagShihTzu

          has_flags({ 1 => :jeanluckpicard }, :column => 'bits')
          has_flags({ 1 => :jeanluckpicard }, :column => 'bits')
        end
           EOF
          )
    end
  end

  def test_has_flags_should_raise_an_exception_when_flag_name_is_not_a_symbol
    assert_raises ArgumentError do
      eval(<<-EOF
        class SpaceshipWithInvalidFlagName < ActiveRecord::Base
          self.table_name = 'spaceships'
          include FlagShihTzu

          has_flags({ 1 => 'error' })
        end
           EOF
          )
    end
  end

  def test_should_define_a_sql_condition_method_for_flag_enabled
    assert_equal "(spaceships.flags in (1,3,5,7))", Spaceship.warpdrive_condition
    assert_equal "(spaceships.flags in (2,3,6,7))", Spaceship.shields_condition
    assert_equal "(spaceships.flags in (4,5,6,7))", Spaceship.electrolytes_condition
  end

  def test_should_accept_a_table_alias_option_for_sql_condition_method
    assert_equal "(old_spaceships.flags in (1,3,5,7))", Spaceship.warpdrive_condition(:table_alias => 'old_spaceships')
  end

  def test_should_define_a_sql_condition_method_for_flag_enabled_with_2_colmns
    assert_equal "(spaceships_with_2_custom_flags_column.bits in (1,3))", SpaceshipWith2CustomFlagsColumn.warpdrive_condition
    assert_equal "(spaceships_with_2_custom_flags_column.bits in (2,3))", SpaceshipWith2CustomFlagsColumn.hyperspace_condition
    assert_equal "(spaceships_with_2_custom_flags_column.commanders in (1,3))", SpaceshipWith2CustomFlagsColumn.jeanlucpicard_condition
    assert_equal "(spaceships_with_2_custom_flags_column.commanders in (2,3))", SpaceshipWith2CustomFlagsColumn.dajanatroj_condition
  end

  def test_should_define_a_sql_condition_method_for_flag_not_enabled
    assert_equal "(spaceships.flags not in (1,3,5,7))", Spaceship.not_warpdrive_condition
    assert_equal "(spaceships.flags not in (2,3,6,7))", Spaceship.not_shields_condition
    assert_equal "(spaceships.flags not in (4,5,6,7))", Spaceship.not_electrolytes_condition
  end

  def test_should_define_a_sql_condition_method_for_flag_enabled_with_custom_table_name
    assert_equal "(custom_spaceships.flags in (1,3,5,7))", Spaceship.send(:sql_condition_for_flag, :warpdrive, 'flags', true, 'custom_spaceships')
  end

  def test_should_define_a_sql_condition_method_for_flag_enabled_with_2_colmns_not_enabled
    assert_equal "(spaceships_with_2_custom_flags_column.bits not in (1,3))", SpaceshipWith2CustomFlagsColumn.not_warpdrive_condition
    assert_equal "(spaceships_with_2_custom_flags_column.bits not in (2,3))", SpaceshipWith2CustomFlagsColumn.not_hyperspace_condition
    assert_equal "(spaceships_with_2_custom_flags_column.commanders not in (1,3))", SpaceshipWith2CustomFlagsColumn.not_jeanlucpicard_condition
    assert_equal "(spaceships_with_2_custom_flags_column.commanders not in (2,3))", SpaceshipWith2CustomFlagsColumn.not_dajanatroj_condition
  end

  def test_should_define_a_sql_condition_method_for_flag_enabled_using_bit_operators
    assert_equal "(spaceships.flags & 1 = 1)", SpaceshipWithBitOperatorQueryMode.warpdrive_condition
    assert_equal "(spaceships.flags & 2 = 2)", SpaceshipWithBitOperatorQueryMode.shields_condition
  end

  def test_should_define_a_sql_condition_method_for_flag_not_enabled_using_bit_operators
    assert_equal "(spaceships.flags & 1 = 0)", SpaceshipWithBitOperatorQueryMode.not_warpdrive_condition
    assert_equal "(spaceships.flags & 2 = 0)", SpaceshipWithBitOperatorQueryMode.not_shields_condition
  end

  def test_should_define_a_named_scope_for_flag_enabled
    assert_where_value "(spaceships.flags in (1,3,5,7))", Spaceship.warpdrive
    assert_where_value "(spaceships.flags in (2,3,6,7))", Spaceship.shields
    assert_where_value "(spaceships.flags in (4,5,6,7))", Spaceship.electrolytes
  end

  def test_should_define_a_named_scope_for_flag_not_enabled
    assert_where_value "(spaceships.flags not in (1,3,5,7))", Spaceship.not_warpdrive
    assert_where_value "(spaceships.flags not in (2,3,6,7))", Spaceship.not_shields
    assert_where_value "(spaceships.flags not in (4,5,6,7))", Spaceship.not_electrolytes
  end

  def test_should_define_a_named_scope_for_flag_enabled_with_2_columns
    assert_where_value "(spaceships_with_2_custom_flags_column.bits in (1,3))", SpaceshipWith2CustomFlagsColumn.warpdrive
    assert_where_value "(spaceships_with_2_custom_flags_column.bits in (2,3))", SpaceshipWith2CustomFlagsColumn.hyperspace
    assert_where_value "(spaceships_with_2_custom_flags_column.commanders in (1,3))", SpaceshipWith2CustomFlagsColumn.jeanlucpicard
    assert_where_value "(spaceships_with_2_custom_flags_column.commanders in (2,3))", SpaceshipWith2CustomFlagsColumn.dajanatroj
  end

  def test_should_define_a_named_scope_for_flag_not_enabled_with_2_columns
    assert_where_value "(spaceships_with_2_custom_flags_column.bits not in (1,3))", SpaceshipWith2CustomFlagsColumn.not_warpdrive
    assert_where_value "(spaceships_with_2_custom_flags_column.bits not in (2,3))", SpaceshipWith2CustomFlagsColumn.not_hyperspace
    assert_where_value "(spaceships_with_2_custom_flags_column.commanders not in (1,3))", SpaceshipWith2CustomFlagsColumn.not_jeanlucpicard
    assert_where_value "(spaceships_with_2_custom_flags_column.commanders not in (2,3))", SpaceshipWith2CustomFlagsColumn.not_dajanatroj
  end

  def test_should_define_a_named_scope_for_flag_enabled_using_bit_operators
    assert_where_value "(spaceships.flags & 1 = 1)", SpaceshipWithBitOperatorQueryMode.warpdrive
    assert_where_value "(spaceships.flags & 2 = 2)", SpaceshipWithBitOperatorQueryMode.shields
  end

  def test_should_define_a_named_scope_for_flag_not_enabled_using_bit_operators
    assert_where_value "(spaceships.flags & 1 = 0)", SpaceshipWithBitOperatorQueryMode.not_warpdrive
    assert_where_value "(spaceships.flags & 2 = 0)", SpaceshipWithBitOperatorQueryMode.not_shields
  end

  def test_should_work_with_raw_sql
    spaceship = Spaceship.new
    spaceship.enable_flag(:shields)
    spaceship.enable_flag(:electrolytes)
    spaceship.save!

    Spaceship.update_all Spaceship.set_flag_sql(:warpdrive, true),
                         ["id=?", spaceship.id]
    spaceship.reload

    assert_equal true, spaceship.warpdrive
    assert_equal true, spaceship.shields
    assert_equal true, spaceship.electrolytes

    spaceship = Spaceship.new
    spaceship.enable_flag(:warpdrive)
    spaceship.enable_flag(:shields)
    spaceship.enable_flag(:electrolytes)
    spaceship.save!

    Spaceship.update_all Spaceship.set_flag_sql(:shields, false),
                         ["id=?", spaceship.id]
    spaceship.reload

    assert_equal true, spaceship.warpdrive
    assert_equal false, spaceship.shields
    assert_equal true, spaceship.electrolytes
  end

  def test_should_return_the_correct_number_of_items_from_a_named_scope
    spaceship = Spaceship.new
    spaceship.enable_flag(:warpdrive)
    spaceship.enable_flag(:shields)
    spaceship.save!
    spaceship.reload
    spaceship_2 = Spaceship.new
    spaceship_2.enable_flag(:warpdrive)
    spaceship_2.save!
    spaceship_2.reload
    spaceship_3 = Spaceship.new
    spaceship_3.enable_flag(:shields)
    spaceship_3.save!
    spaceship_3.reload
    assert_equal 1, Spaceship.not_warpdrive.count
    assert_equal 2, Spaceship.warpdrive.count
    assert_equal 1, Spaceship.not_shields.count
    assert_equal 2, Spaceship.shields.count
    assert_equal 1, Spaceship.warpdrive.shields.count
    assert_equal 0, Spaceship.not_warpdrive.not_shields.count
  end

  def test_should_not_define_named_scopes_if_not_wanted
    assert !SpaceshipWithoutNamedScopes.respond_to?(:warpdrive)
    assert !SpaceshipWithoutNamedScopesOldStyle.respond_to?(:warpdrive)
  end

  def test_should_work_with_a_custom_flags_column
    spaceship = SpaceshipWithCustomFlagsColumn.new
    spaceship.enable_flag(:warpdrive)
    spaceship.enable_flag(:hyperspace)
    spaceship.save!
    spaceship.reload
    assert_equal 3, spaceship.flags('bits')
    assert_equal "(spaceships_with_custom_flags_column.bits in (1,3))", SpaceshipWithCustomFlagsColumn.warpdrive_condition
    assert_equal "(spaceships_with_custom_flags_column.bits not in (1,3))", SpaceshipWithCustomFlagsColumn.not_warpdrive_condition
    assert_equal "(spaceships_with_custom_flags_column.bits in (2,3))", SpaceshipWithCustomFlagsColumn.hyperspace_condition
    assert_equal "(spaceships_with_custom_flags_column.bits not in (2,3))", SpaceshipWithCustomFlagsColumn.not_hyperspace_condition
    assert_where_value "(spaceships_with_custom_flags_column.bits in (1,3))", SpaceshipWithCustomFlagsColumn.warpdrive
    assert_where_value "(spaceships_with_custom_flags_column.bits not in (1,3))", SpaceshipWithCustomFlagsColumn.not_warpdrive
    assert_where_value "(spaceships_with_custom_flags_column.bits in (2,3))", SpaceshipWithCustomFlagsColumn.hyperspace
    assert_where_value "(spaceships_with_custom_flags_column.bits not in (2,3))", SpaceshipWithCustomFlagsColumn.not_hyperspace
  end

  def test_should_work_with_a_custom_flags_column_name_as_symbol
    spaceship = SpaceshipWithColumnNameAsSymol.new
    spaceship.enable_flag(:warpdrive)
    spaceship.save!
    spaceship.reload
    assert_equal 1, spaceship.flags('bits')
  end

  def test_should_not_error_out_when_table_is_not_present
    assert_nothing_raised(ActiveRecord::StatementInvalid) do
      Planet.class_eval do
        include FlagShihTzu
        has_flags(1 => :habitable)
      end
    end
  end

  private

  def assert_where_value(expected, scope)
    assert_equal expected,
      ActiveRecord::VERSION::MAJOR == 2 ? scope.proxy_options[:conditions] : scope.where_values.first
  end

end

class FlagShihTzuInstanceMethodsTest < Test::Unit::TestCase

  def setup
    @spaceship = Spaceship.new
    @big_spaceship = SpaceshipWith2CustomFlagsColumn.new
    @small_spaceship = SpaceshipWithCustomFlagsColumn.new
  end

  def test_should_enable_flag
    @spaceship.enable_flag(:warpdrive)
    assert @spaceship.flag_enabled?(:warpdrive)
  end

  def test_should_enable_flag_with_2_columns
    @big_spaceship.enable_flag(:warpdrive)
    assert @big_spaceship.flag_enabled?(:warpdrive)
    @big_spaceship.enable_flag(:jeanlucpicard)
    assert @big_spaceship.flag_enabled?(:jeanlucpicard)
  end

  def test_should_disable_flag
    @spaceship.enable_flag(:warpdrive)
    assert @spaceship.flag_enabled?(:warpdrive)

    @spaceship.disable_flag(:warpdrive)
    assert @spaceship.flag_disabled?(:warpdrive)
  end

  def test_should_disable_flag_with_2_columns
    @big_spaceship.enable_flag(:warpdrive)
    assert @big_spaceship.flag_enabled?(:warpdrive)
    @big_spaceship.enable_flag(:jeanlucpicard)
    assert @big_spaceship.flag_enabled?(:jeanlucpicard)

    @big_spaceship.disable_flag(:warpdrive)
    assert @big_spaceship.flag_disabled?(:warpdrive)
    @big_spaceship.disable_flag(:jeanlucpicard)
    assert @big_spaceship.flag_disabled?(:jeanlucpicard)
  end

  def test_should_store_the_flags_correctly
    @spaceship.enable_flag(:warpdrive)
    @spaceship.disable_flag(:shields)
    @spaceship.enable_flag(:electrolytes)

    @spaceship.save!
    @spaceship.reload

    assert_equal 5, @spaceship.flags
    assert @spaceship.flag_enabled?(:warpdrive)
    assert !@spaceship.flag_enabled?(:shields)
    assert @spaceship.flag_enabled?(:electrolytes)
  end

  def test_should_store_the_flags_correctly_wiht_2_colmns
    @big_spaceship.enable_flag(:warpdrive)
    @big_spaceship.disable_flag(:hyperspace)
    @big_spaceship.enable_flag(:dajanatroj)

    @big_spaceship.save!
    @big_spaceship.reload

    assert_equal 1, @big_spaceship.flags('bits')
    assert_equal 2, @big_spaceship.flags('commanders')

    assert @big_spaceship.flag_enabled?(:warpdrive)
    assert !@big_spaceship.flag_enabled?(:hyperspace)
    assert @big_spaceship.flag_enabled?(:dajanatroj)
  end

  def test_enable_flag_should_leave_the_flag_enabled_when_called_twice
    2.times do
      @spaceship.enable_flag(:warpdrive)
      assert @spaceship.flag_enabled?(:warpdrive)
    end
  end

  def test_disable_flag_should_leave_the_flag_disabled_when_called_twice
    2.times do
      @spaceship.disable_flag(:warpdrive)
      assert !@spaceship.flag_enabled?(:warpdrive)
    end
  end

  def test_should_define_an_attribute_reader_method
    assert_equal false, @spaceship.warpdrive
  end

  # --------------------------------------------------

  def test_should_define_an_all_flags_reader_method
    assert_array_similarity [:electrolytes, :warpdrive, :shields], @spaceship.all_flags('flags')
  end

  def test_should_define_a_selected_flags_reader_method
    assert_array_similarity [], @spaceship.selected_flags('flags')

    @spaceship.warpdrive = true
    assert_array_similarity [:warpdrive], @spaceship.selected_flags('flags')

    @spaceship.electrolytes = true
    assert_array_similarity [:electrolytes, :warpdrive], @spaceship.selected_flags('flags')

    @spaceship.warpdrive = false
    @spaceship.electrolytes = false
    assert_array_similarity [], @spaceship.selected_flags('flags')
  end

  def test_should_define_a_select_all_flags_method
    @spaceship.select_all_flags('flags')
    assert @spaceship.warpdrive
    assert @spaceship.shields
    assert @spaceship.electrolytes
  end

  def test_should_define_an_unselect_all_flags_method
    @spaceship.warpdrive = true
    @spaceship.shields = true
    @spaceship.electrolytes = true

    @spaceship.unselect_all_flags('flags')

    assert !@spaceship.warpdrive
    assert !@spaceship.shields
    assert !@spaceship.electrolytes
  end

  def test_should_define_an_has_flag_method
    assert !@spaceship.has_flag?('flags')

    @spaceship.warpdrive = true
    assert @spaceship.has_flag?('flags')

    @spaceship.shields = true
    assert @spaceship.has_flag?('flags')

    @spaceship.electrolytes = true
    assert @spaceship.has_flag?('flags')

    @spaceship.unselect_all_flags('flags')
    assert !@spaceship.has_flag?('flags')
  end

  # --------------------------------------------------

  def test_should_define_a_customized_all_flags_reader_method
    assert_array_similarity [:hyperspace, :warpdrive], @small_spaceship.all_bits
  end

  def test_should_define_a_customized_selected_flags_reader_method
    assert_array_similarity [], @small_spaceship.selected_bits

    @small_spaceship.warpdrive = true
    assert_array_similarity [:warpdrive], @small_spaceship.selected_bits

    @small_spaceship.hyperspace = true
    assert_array_similarity [:hyperspace, :warpdrive], @small_spaceship.selected_bits

    @small_spaceship.warpdrive = false
    @small_spaceship.hyperspace = false
    assert_array_similarity [], @small_spaceship.selected_bits
  end

  def test_should_define_a_customized_select_all_flags_method
    @small_spaceship.select_all_bits
    assert @small_spaceship.warpdrive
    assert @small_spaceship.hyperspace
  end

  def test_should_define_a_customized_unselect_all_flags_method
    @small_spaceship.warpdrive = true
    @small_spaceship.hyperspace = true

    @small_spaceship.unselect_all_bits

    assert !@small_spaceship.warpdrive
    assert !@small_spaceship.hyperspace
  end

  def test_should_define_a_customized_selected_flags_writer_method
    @small_spaceship.selected_bits = [:warpdrive]
    assert @small_spaceship.warpdrive
    assert !@small_spaceship.hyperspace

    @small_spaceship.selected_bits = [:hyperspace]
    assert !@small_spaceship.warpdrive
    assert @small_spaceship.hyperspace

    @small_spaceship.selected_bits = [:hyperspace, :warpdrive]
    assert @small_spaceship.warpdrive
    assert @small_spaceship.hyperspace

    @small_spaceship.selected_bits = []
    assert !@small_spaceship.warpdrive
    assert !@small_spaceship.hyperspace
  end

  def test_should_define_a_customized_has_flag_method
    assert !@small_spaceship.has_bit?

    @small_spaceship.warpdrive = true
    assert @small_spaceship.has_bit?

    @small_spaceship.hyperspace = true
    assert @small_spaceship.has_bit?

    @small_spaceship.unselect_all_bits
    assert !@small_spaceship.has_bit?
  end

  # --------------------------------------------------

  def test_should_define_a_customized_all_flags_reader_method_with_2_columns
    assert_array_similarity [:hyperspace, :warpdrive], @big_spaceship.all_bits
    assert_array_similarity [:dajanatroj, :jeanlucpicard], @big_spaceship.all_commanders
  end

  def test_should_define_a_customized_selected_flags_reader_method_with_2_columns
    assert_array_similarity [], @big_spaceship.selected_bits
    assert_array_similarity [], @big_spaceship.selected_commanders

    @big_spaceship.warpdrive = true
    @big_spaceship.jeanlucpicard = true
    assert_array_similarity [:warpdrive], @big_spaceship.selected_bits
    assert_array_similarity [:jeanlucpicard], @big_spaceship.selected_commanders

    @big_spaceship.hyperspace = true
    @big_spaceship.hyperspace = true
    @big_spaceship.jeanlucpicard = true
    @big_spaceship.dajanatroj = true
    assert_array_similarity [:hyperspace, :warpdrive], @big_spaceship.selected_bits
    assert_array_similarity [:dajanatroj, :jeanlucpicard], @big_spaceship.selected_commanders

    @big_spaceship.warpdrive = false
    @big_spaceship.hyperspace = false
    @big_spaceship.jeanlucpicard = false
    @big_spaceship.dajanatroj = false
    assert_array_similarity [], @big_spaceship.selected_bits
    assert_array_similarity [], @big_spaceship.selected_commanders
  end

  def test_should_define_a_customized_select_all_flags_method_with_2_columns
    @big_spaceship.select_all_bits
    @big_spaceship.select_all_commanders
    assert @big_spaceship.warpdrive
    assert @big_spaceship.hyperspace
    assert @big_spaceship.jeanlucpicard
    assert @big_spaceship.dajanatroj
  end

  def test_should_define_a_customized_unselect_all_flags_method_with_2_columns
    @big_spaceship.warpdrive = true
    @big_spaceship.hyperspace = true
    @big_spaceship.jeanlucpicard = true
    @big_spaceship.dajanatroj = true

    @big_spaceship.unselect_all_bits
    @big_spaceship.unselect_all_commanders

    assert !@big_spaceship.warpdrive
    assert !@big_spaceship.hyperspace
    assert !@big_spaceship.jeanlucpicard
    assert !@big_spaceship.dajanatroj
  end

  def test_should_define_a_customized_selected_flags_writer_method_with_2_columns
    @big_spaceship.selected_bits = [:warpdrive]
    @big_spaceship.selected_commanders = [:jeanlucpicard]
    assert @big_spaceship.warpdrive
    assert !@big_spaceship.hyperspace
    assert @big_spaceship.jeanlucpicard
    assert !@big_spaceship.dajanatroj

    @big_spaceship.selected_bits = [:hyperspace]
    @big_spaceship.selected_commanders = [:dajanatroj]
    assert !@big_spaceship.warpdrive
    assert @big_spaceship.hyperspace
    assert !@big_spaceship.jeanlucpicard
    assert @big_spaceship.dajanatroj

    @big_spaceship.selected_bits = [:hyperspace, :warpdrive]
    @big_spaceship.selected_commanders = [:dajanatroj, :jeanlucpicard]
    assert @big_spaceship.warpdrive
    assert @big_spaceship.hyperspace
    assert @big_spaceship.jeanlucpicard
    assert @big_spaceship.dajanatroj

    @big_spaceship.selected_bits = []
    @big_spaceship.selected_commanders = []
    assert !@big_spaceship.warpdrive
    assert !@big_spaceship.hyperspace
    assert !@big_spaceship.jeanlucpicard
    assert !@big_spaceship.dajanatroj
  end

  def test_should_define_a_customized_has_flag_method_with_2_columns
    assert !@big_spaceship.has_bit?
    assert !@big_spaceship.has_commander?

    @big_spaceship.warpdrive = true
    @big_spaceship.jeanlucpicard = true
    assert @big_spaceship.has_bit?
    assert @big_spaceship.has_commander?

    @big_spaceship.hyperspace = true
    @big_spaceship.dajanatroj = true
    assert @big_spaceship.has_bit?

    @big_spaceship.unselect_all_bits
    @big_spaceship.unselect_all_commanders
    assert !@big_spaceship.has_bit?
  end

  # --------------------------------------------------

  def test_should_define_an_attribute_reader_predicate_method
    assert_equal false, @spaceship.warpdrive?
  end

  def test_should_define_an_attribute_writer_method
    @spaceship.warpdrive = true
    assert @spaceship.warpdrive
  end

  def test_should_define_dirty_suffix_changed?
    assert !@spaceship.warpdrive_changed?
    assert !@spaceship.shields_changed?

    @spaceship.enable_flag(:warpdrive)
    assert @spaceship.warpdrive_changed?
    assert !@spaceship.shields_changed?

    @spaceship.enable_flag(:shields)
    assert @spaceship.warpdrive_changed?
    assert @spaceship.shields_changed?

    @spaceship.disable_flag(:warpdrive)
    assert !@spaceship.warpdrive_changed?
    assert @spaceship.shields_changed?

    @spaceship.disable_flag(:shields)
    assert !@spaceship.warpdrive_changed?
    assert !@spaceship.shields_changed?
  end

  def test_should_respect_true_values_like_active_record
    [true, 1, '1', 't', 'T', 'true', 'TRUE'].each do |true_value|
      @spaceship.warpdrive = true_value
      assert @spaceship.warpdrive
    end

    [false, 0, '0', 'f', 'F', 'false', 'FALSE'].each do |false_value|
      @spaceship.warpdrive = false_value
      assert !@spaceship.warpdrive
    end
  end

  def test_should_ignore_has_flags_call_if_column_does_not_exist_yet
    assert_nothing_raised do
      eval(<<-EOF
        class SpaceshipWithoutFlagsColumn < ActiveRecord::Base
          self.table_name = 'spaceships_without_flags_column'
          include FlagShihTzu

          has_flags 1 => :warpdrive,
                    2 => :shields,
                    3 => :electrolytes
        end
      EOF
      )
    end

    assert !SpaceshipWithoutFlagsColumn.method_defined?(:warpdrive)
  end

  def test_should_ignore_has_flags_call_if_column_not_integer
    assert_raises FlagShihTzu::IncorrectFlagColumnException do
      eval(<<-EOF
        class SpaceshipWithNonIntegerColumn < ActiveRecord::Base
          self.table_name ='spaceships_with_non_integer_column'
          include FlagShihTzu

          has_flags 1 => :warpdrive,
                    2 => :shields,
                    3 => :electrolytes
        end
      EOF
      )
    end

    assert !SpaceshipWithoutFlagsColumn.method_defined?(:warpdrive)
  end

  def test_column_guessing_for_default_column
    assert_equal 'flags', @spaceship.class.determine_flag_colmn_for(:warpdrive)
  end

  def test_column_guessing_for_default_column
    assert_raises FlagShihTzu::NoSuchFlagException do
      @spaceship.class.determine_flag_colmn_for(:xxx)
    end
  end

  def test_column_guessing_for_2_columns
    assert_equal 'commanders', @big_spaceship.class.determine_flag_colmn_for(:jeanlucpicard)
    assert_equal 'bits', @big_spaceship.class.determine_flag_colmn_for(:warpdrive)
  end

  # --------------------------------------------------

  def test_validation_should_raise_if_not_a_flag_column
    spaceship = SpaceshipWithValidationsOnNonFlagsColumn.new
    assert_raises ArgumentError do
      spaceship.valid?
    end
  end

  def test_validation_should_succeed_with_a_blank_optional_flag
    spaceship = Spaceship.new
    assert_equal true, spaceship.valid?
  end

  def test_validation_should_fail_with_a_nil_required_flag
    spaceship = SpaceshipWithValidationsAndCustomFlagsColumn.new
    spaceship.bits = nil
    assert_equal false, spaceship.valid?
    assert_equal ["can't be blank"], spaceship.errors.messages[:bits]
  end

  def test_validation_should_fail_with_a_blank_required_flag
    spaceship = SpaceshipWithValidationsAndCustomFlagsColumn.new
    assert_equal false, spaceship.valid?
    assert_equal ["can't be blank"], spaceship.errors.messages[:bits]
  end

  def test_validation_should_succeed_with_a_set_required_flag
    spaceship = SpaceshipWithValidationsAndCustomFlagsColumn.new
    spaceship.warpdrive = true
    assert_equal true, spaceship.valid?
  end

  def test_validation_should_fail_with_a_blank_required_flag_among_2
    spaceship = SpaceshipWithValidationsAnd3CustomFlagsColumn.new
    assert_equal false, spaceship.valid?
    assert_equal ["can't be blank"], spaceship.errors.messages[:engines]
    assert_equal ["can't be blank"], spaceship.errors.messages[:weapons]

    spaceship.warpdrive = true
    assert_equal false, spaceship.valid?
    assert_equal ["can't be blank"], spaceship.errors.messages[:weapons]
  end

  def test_validation_should_succeed_with_a_set_required_flag_among_2
    spaceship = SpaceshipWithValidationsAnd3CustomFlagsColumn.new
    spaceship.warpdrive = true
    spaceship.photon = true
    assert_equal true, spaceship.valid?
  end

end

class FlagShihTzuDerivedClassTest < Test::Unit::TestCase

  def setup
    @spaceship = SpaceCarrier.new
  end

  def test_should_enable_flag
    @spaceship.enable_flag(:warpdrive)
    assert @spaceship.flag_enabled?(:warpdrive)
  end

  def test_should_disable_flag
    @spaceship.enable_flag(:warpdrive)
    assert @spaceship.flag_enabled?(:warpdrive)

    @spaceship.disable_flag(:warpdrive)
    assert @spaceship.flag_disabled?(:warpdrive)
  end

  def test_should_store_the_flags_correctly
    @spaceship.enable_flag(:warpdrive)
    @spaceship.disable_flag(:shields)
    @spaceship.enable_flag(:electrolytes)

    @spaceship.save!
    @spaceship.reload

    assert_equal 5, @spaceship.flags
    assert @spaceship.flag_enabled?(:warpdrive)
    assert !@spaceship.flag_enabled?(:shields)
    assert @spaceship.flag_enabled?(:electrolytes)
  end

  def test_enable_flag_should_leave_the_flag_enabled_when_called_twice
    2.times do
      @spaceship.enable_flag(:warpdrive)
      assert @spaceship.flag_enabled?(:warpdrive)
    end
  end

  def test_disable_flag_should_leave_the_flag_disabled_when_called_twice
    2.times do
      @spaceship.disable_flag(:warpdrive)
      assert !@spaceship.flag_enabled?(:warpdrive)
    end
  end

  def test_should_define_an_attribute_reader_method
    assert_equal false, @spaceship.warpdrive?
  end

  def test_should_define_an_attribute_writer_method
    @spaceship.warpdrive = true
    assert @spaceship.warpdrive
  end

  def test_should_respect_true_values_like_active_record
    [true, 1, '1', 't', 'T', 'true', 'TRUE'].each do |true_value|
      @spaceship.warpdrive = true_value
      assert @spaceship.warpdrive
    end

    [false, 0, '0', 'f', 'F', 'false', 'FALSE'].each do |false_value|
      @spaceship.warpdrive = false_value
      assert !@spaceship.warpdrive
    end
  end

  def test_should_define_bang_methods
    spaceship = SpaceshipWithBangMethods.new
    spaceship.warpdrive!
    assert spaceship.warpdrive
    spaceship.not_warpdrive!
    assert !spaceship.warpdrive
  end

  def test_should_return_a_sql_set_method_for_flag
    assert_equal "flags = flags | 1",  Spaceship.send( :sql_set_for_flag, :warpdrive, 'flags', true)
    assert_equal "flags = flags & ~1", Spaceship.send( :sql_set_for_flag, :warpdrive, 'flags', false)
  end

end

class FlagShihTzuClassMethodsTest < Test::Unit::TestCase

  def test_should_track_columns_used_by_FlagShihTzu
    assert_equal Spaceship.flag_columns, ['flags']
    assert_equal SpaceshipWith2CustomFlagsColumn.flag_columns, ['bits', 'commanders']
    assert_equal SpaceshipWith3CustomFlagsColumn.flag_columns, ['engines', 'weapons', 'hal3000']
  end

end
