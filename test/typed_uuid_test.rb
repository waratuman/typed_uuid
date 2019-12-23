require 'test_helper'

class FilterTest < ActiveSupport::TestCase

  schema do
    ActiveRecord::Base.register_uuid_types({
      listings: 0,
      buildings: 65_535
    })
    
    create_table :listings, id: :typed_uuid do |t|
      t.string   "name", limit: 255
    end
    
    create_table :buildings, id: :typed_uuid do |t|
      t.string   "name", limit: 255
    end
  end
  
  class Listing < ActiveRecord::Base
  end
  
  class Building < ActiveRecord::Base
  end

  test 'adding primary key as a typed_uuid in a migration' do
    ActiveRecord::Base.register_uuid_types({
      properties: 1
    })

    exprexted_sql = <<-SQL
      CREATE TABLE "properties" ("id" uuid DEFAULT typed_uuid('\\x1000') NOT NULL PRIMARY KEY, "name" character varying(255))
    SQL

    assert_sql exprexted_sql do
      ActiveRecord::Migration.suppress_messages do
        ActiveRecord::Migration.create_table :properties, id: :typed_uuid do |t|
          t.string   "name",                    limit: 255
        end
      end
    end
  end

  test 'class_from uuid' do
    listing = Listing.create
    building = Building.create
    
    assert_equal FilterTest::Listing, ::ActiveRecord::Base.class_from_uuid(listing.id)
    assert_equal FilterTest::Building, ::ActiveRecord::Base.class_from_uuid(building.id)
  end
  
  test 'uuid_type from table_name' do
    assert_equal 0, ::ActiveRecord::Base.uuid_type_from_table_name(:listings)
    assert_equal 0, ::ActiveRecord::Base.uuid_type_from_table_name('listings')
    assert_equal 65_535, ::ActiveRecord::Base.uuid_type_from_table_name(:buildings)
  end
  
  test 'class from uuid_type' do
    assert_equal FilterTest::Listing, ::ActiveRecord::Base.class_from_uuid_type(0)
    assert_equal FilterTest::Building, ::ActiveRecord::Base.class_from_uuid_type(65_535)
  end
  
end