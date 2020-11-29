# TypedUUID

A __Typed UUID__ is an UUID with an enum embeded within the UUID.

UUIDs are 128bit or 16bytes. The hex format is represented below where x is
a hex representation of 4 bits.

`xxxxxxxx-xxxx-Mxxx-Nxxx-xxxxxxxxxxxx`

- M is 4 bits and is the Version
- N is 3 bits and is the Variant of the Version followed a bit

We modify this and use the following structure where the 9th & 10th bytes in the
UUID are the enum XORed with the result of XORing bytes 7 & 8 with bytes 11 & 12.

`xxxxxxxx-xxxx-YYYY-TTTT-ZZZZxxxxxxxx`

Where:

- TTTT is the Type ENUM & Version 0bEEEE_EEEE_EEEE_EVVV; XORed with (YYYY xor ZZZZ)
    - The Es are the bits of the 13 bit ENUM supporting 8,192 enums/types (0 - 8,191)
    - The Vs are the bits in the 3 bit version supporting 8 versions (0 - 7)
- YYYY bytes XORed with ZZZZ and the Type ENUM to produce the identifying bytes
- ZZZZ bytes XORed with YYYY and the Type ENUM to produce the identifying bytes

XORing bytes 7 & 8 with 11 & 12 and XORing again with bytes 9 & 10 of the
Typed UUID will give us back the ENUM and Version of the Type using soley the UUID.

## Versions

As with regular UUID Typed UUIDs come in multiple version. The current versions are:

- Version 1: A timebased UUID where the first 64 bits are an unsigned integer
             representing the nanoseconds since epoch. The following 16 bits are
             the UUID type folled by 48 random bits.

- Version 4: A random UUID where the first 64 bits are random. The following
             16 bits are the UUID type folled by another 48 random bits.

## Install

Add this to your Gemfile:

`gem 'typed_uuid'`

Once bundled you can add an initializer to Rails to register your types as shown
below. This maps the __Model Classes__ to an integer between 0 and 65,535.

```ruby
# config/initializers/uuid_types.rb

ActiveRecord::Base.register_uuid_types({
  Listing: 	                0,
  Address:                  {enum: 5},
  Building:                 {enum: 512, version: 1},
  'Building::SkyScrpaer' => 8_191
})

# Or:

ActiveRecord::Base.register_uuid_types({
  0         => :Listing,
  512       => :Building,
  8_191    => 'Building::SkyScrpaer'
})
```


## Usage

In your migrations simply replace `id: :uuid` with `id: :typed_uuid` when creating
a table.

```ruby
class CreateProperties < ActiveRecord::Migration[5.2]
  def change	
	create_table :properties, id: :typed_uuid do |t|
      t.string "name", limit: 255
    end
  end
end
```

## STI Models
When using STI Model Rails will generate the UUID to be inserted. This UUID will
be calculated of the STI Model class and not the base class.

In the migration you can still used `id: :typed_uuid`, this will use the base
class to calculated the default type for the UUID. You could also set the
`id` to `:uuid` and the `default` to `false` so when no ID is given it will error.