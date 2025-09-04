require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products # Already loaded by convention, but here for clarity
  def new_product(filename, content_type)
    Product.new(
      title: "My Book Title",
      description: "yyy",
      price: 1
    ).tap do |product| # tap yields the object to a block and returns the original object. Commonly used in initialization
      product.image.attach(
        io: File.open("test/fixtures/files/#{filename}"),
        filename:, content_type: # Introduced in Ruby 2.1, filename: is equivalent to filename: filename
      )
    end
  end

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image].any?
  end

  test "product price must be positive" do
    product = new_product("lorem.jpg", "image/jpg")
    product.price = -1
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal [ "must be greater than or equal to 0.01"], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  test "image url" do
    produce = new_product("lorem.jpg", "image/jpeg")
    assert produce.valid?, "image/jpeg must be valid"

    product = new_product("logo.svg", "image/svg+xml")
    assert_not product.valid?, "image/svg+xml must be invalid"
  end

  test "product is not valid without a unique title" do
    product = Product.new(title: products(:pragprog).title,
                          description: products(:pragprog).description,
                          price: products(:pragprog).price)
    product.image.attach(io: File.open("test/fixtures/files/lorem.jpg"),
                         filename: "lorem.jpg", content_type: "image/jpeg")
    assert product.invalid?
    assert_equal [I18n.translate("errors.messages.taken")],
                 product.errors[:title]
  end

end
