/**
* Copyright © DiamondMVC 2018
* License: MIT (https://github.com/DiamondMVC/Diamond/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module diamond.seo.schema.structures.organizations.localbusiness;

import diamond.core.apptype;

static if (isWeb)
{
  import diamond.seo.schema.structures.organization;

  /// http://schema.org/LocalBusiness
  class LocalBusiness : Organization
  {
    private:
    /// The image.
    string _image;
    /// The opening hours.
    string[] _openingHours;
    /// The price range.
    string _priceRange;

    public:
    /// Creates a new local business.
    this()
    {
      super("LocalBusiness");
    }

    /**
    * Creates a new local business.
    * Params:
    *   localBusinessType = The type of the local business.
    */
    protected this(string localBusinessType)
    {
      super(localBusinessType);
    }

    @property
    {
      final
      {
        /// Gets the image.
        string image() { return _image; }

        /// Sets the image.
        void image(string newImage)
        {
          _image = newImage;

          super.addField("image", _image);
        }

        /// Gets the opening hours.
        string[] openingHours() { return _openingHours; }

        /// Sets the opening hours.
        void openingHours(string[] newOpeningHours)
        {
          _openingHours = newOpeningHours;

          super.addField("openingHours", _openingHours);
        }

        /// Gets the price range.
        string priceRange() { return _priceRange; }

        /// Sets the price range.
        void priceRange(string newPriceRange)
        {
          _priceRange = newPriceRange;

          super.addField("priceRange", _priceRange);
        }
      }
    }
  }
}
